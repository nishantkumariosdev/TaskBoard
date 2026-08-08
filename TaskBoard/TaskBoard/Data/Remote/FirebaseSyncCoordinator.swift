//
//  FirebaseSyncCoordinator.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class FirebaseSyncCoordinator: SyncCoordinating {
    private static let debounce = Duration.seconds(1)
    private static let pollInterval = Duration.seconds(30)

    private let engine: SyncEngine
    private let network: NetworkMonitor

    private var status = SyncStatus()
    private var observers: [UUID: AsyncStream<SyncStatus>.Continuation] = [:]

    private var debounceTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var changesTask: Task<Void, Never>?
    private var isSyncing = false
    private var isStarted = false
    private var needsAnotherPass = false

    private enum Trigger: String {
        case launch
        case connectivity
        case localChange = "local change"
        case poll
        case manual
    }

    init(engine: SyncEngine, network: NetworkMonitor) {
        self.engine = engine
        self.network = network
    }

    deinit {
        debounceTask?.cancel()
        pollTask?.cancel()
        changesTask?.cancel()
    }

    func observeStatus() -> AsyncStream<SyncStatus> {
        AsyncStream { continuation in
            let id = UUID()
            observers[id] = continuation
            continuation.yield(status)

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.observers[id] = nil }
            }
        }
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        network.start { [weak self] isOnline in
            guard let self else { return }
            AppLog.sync("connectivity: \(isOnline ? "online" : "offline")")
            self.status.isOnline = isOnline
            self.publish()
            if isOnline { self.request(.connectivity) }
        }

        status.isOnline = network.isOnline
        refreshPendingCount()
        
        changesTask = Task { [weak self] in
            guard let self else { return }
            for await _ in self.engine.observeLocalChanges() {
                self.refreshPendingCount()
            }
        }

        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard !Task.isCancelled else { return }
                await self?.run(.poll)
            }
        }

        Task { await run(.launch) }
    }

    func syncNow() async {
        await run(.manual)
    }

    func requestSync() {
        request(.localChange)
    }

    private func run(_ trigger: Trigger) async {
        guard !isSyncing else {
            needsAnotherPass = true
            AppLog.sync("\(trigger.rawValue) arrived, will run again after")
            return
        }
        AppLog.sync("pass started, trigger: \(trigger.rawValue)")

        isSyncing = true
        status.isSyncing = true
        publish()

        var succeeded = false
        repeat {
            needsAnotherPass = false
            succeeded = await engine.sync()
        } while needsAnotherPass

        isSyncing = false
        status.isSyncing = false
        status.pendingCount = engine.pendingCount()
        if succeeded {
            status.lastSyncedAt = Date()
            status.isOnline = true
        }
        publish()
    }

    private func request(_ trigger: Trigger) {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }
            await self?.run(trigger)
        }
    }

    private func publish() {
        for continuation in observers.values {
            continuation.yield(status)
        }
    }
    
    private func refreshPendingCount() {
        let count = engine.pendingCount()
        guard count != status.pendingCount else { return }
        status.pendingCount = count
        publish()
    }
}

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
            self.status.isOnline = isOnline
            self.publish()
            if isOnline { self.requestSync() }
        }

        status.isOnline = network.isOnline
        refreshPendingCount()
        
        changesTask = Task { [weak self] in
            guard let self else { return }
            for await _ in self.engine.observerLocalChanges() {
                self.refreshPendingCount()
            }
        }

        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard !Task.isCancelled else { return }
                await self?.syncNow()
            }
        }

        Task { await syncNow() }
    }

    func syncNow() async {
        guard !isSyncing else {
            needsAnotherPass = true
            return
        }

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

    func requestSync() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }
            await self?.syncNow()
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

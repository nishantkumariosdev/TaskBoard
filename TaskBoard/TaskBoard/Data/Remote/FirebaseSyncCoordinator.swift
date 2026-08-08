//
//  FirebaseSyncCoordinator.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class FirebaseSyncCoordinator: SyncCoordinating {
    private static let pollInterval = Duration.seconds(30)
    private let engine: SyncEngine

    private var lastSyncedAt: Date?
    private var observers: [UUID: AsyncStream<Date?>.Continuation] = [:]

    private var pendingWork: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var isStarted = false

    init(engine: SyncEngine) {
        self.engine = engine
    }

    deinit {
        pendingWork?.cancel()
        pollTask?.cancel()
    }

    func observeLastSynced() -> AsyncStream<Date?> {
        AsyncStream { continuation in
            let id = UUID()
            observers[id] = continuation
            continuation.yield(lastSyncedAt)

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.observers[id] = nil }
            }
        }
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        enqueue { await self.engine.pull() }

        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard !Task.isCancelled else { return }
                await self?.refresh()
            }
        }
    }

    func refresh() async {
        await enqueueAndWait { await self.engine.pull() }
    }

    func push(_ task: BoardTask) {
        enqueue { await self.engine.push(task) }
    }

    func pushDelete(id: String) {
        enqueue { await self.engine.pushDelete(id: id) }
    }
    
    private func enqueue(_ operation: @escaping @MainActor () async -> Bool) {
        let previous = pendingWork
        pendingWork = Task { @MainActor in
            await previous?.value
            let succeeded = await operation()
            if succeeded { recordSuccess() }
        }
    }

    private func enqueueAndWait(_ operation: @escaping @MainActor () async -> Bool) async {
        enqueue(operation)
        await pendingWork?.value
    }

    private func recordSuccess() {
        lastSyncedAt = Date()
        for continuation in observers.values {
            continuation.yield(lastSyncedAt)
        }
    }
}

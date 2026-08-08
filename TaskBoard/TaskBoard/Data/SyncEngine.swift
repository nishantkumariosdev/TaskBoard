//
//  SyncEngine.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class SyncEngine {
    private let store: LocalTaskStore
    private let remote: RemoteTaskDataSource

    init(store: LocalTaskStore, remote: RemoteTaskDataSource) {
        self.store = store
        self.remote = remote
    }
    
    func pendingCount() -> Int {
        (try? store.fetchPending().count) ?? 0
    }
    
    func observeLocalChanges() -> AsyncStream<[BoardTask]> {
        store.observe()
    }
    
    func sync() async -> Bool {
        let pushed = await push()
        let pulled = await pull()
        let succeeded = pushed && pulled

        AppLog.sync("pass \(succeeded ? "ok" : "incomplete"), \(pendingCount()) still pending")
        return succeeded
    }

    private func push() async -> Bool {
        guard let pending = try? store.fetchPending(), !pending.isEmpty else { return true }

        AppLog.sync("pushing \(pending.count) change")
        var allSucceeded = true
        for task in pending {
            do {
                if task.syncState == .pendingDelete {
                    try await remote.delete(id: task.id)
                } else {
                    try await remote.upsert(task)
                    try store.markSynced(id: task.id)
                }
            } catch {
                AppLog.sync("send \(task.id) failed, \((error as? BoardError)?.errorDescription ?? error.localizedDescription)")
                allSucceeded = false
                continue
            }
            
            do {
                if task.syncState == .pendingDelete {
                    try store.hardDelete(ids: [task.id])
                } else {
                    try store.markSynced(id: task.id)
                }
            } catch {
                AppLog.sync("sent \(task.id) but could not mark it, \((error as? BoardError)?.errorDescription ?? error.localizedDescription)")
                allSucceeded = false
            }
        }

        return allSucceeded
    }

    private func pull() async -> Bool {
        do {
            let serverTasks = try await remote.fetchAll()
            let locals = try store.fetchAllIncludingDeleted()
            let localsByID = Dictionary(locals.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

            let incoming = serverTasks.filter { serverTask in
                guard let local = localsByID[serverTask.id] else { return true }
                return ConflictResolver.resolve(local: local, server: serverTask) == .takeServer
            }
            if !incoming.isEmpty {
                try store.upsert(incoming.map { $0.markedSynced() })
            }
            let serverIDs = Set(serverTasks.map(\.id))
            let deletedElsewhere = locals
                .filter { $0.syncState == .synced && !serverIDs.contains($0.id) }
                .map(\.id)

            if !deletedElsewhere.isEmpty {
                try store.hardDelete(ids: deletedElsewhere)
            }

            AppLog.sync("pulled \(serverTasks.count) from server, \(incoming.count) applied, \(deletedElsewhere.count) removed")
            return true
        } catch {
            return false
        }
    }
}

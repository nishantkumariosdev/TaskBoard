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

    func push(_ task: BoardTask) async -> Bool {
        do {
            try await remote.upsert(task)
            return true
        } catch {
            return false
        }
    }

    func pushDelete(id: String) async -> Bool {
        do {
            try await remote.delete(id: id)
            return true
        } catch {
            return false
        }
    }

    func pull() async -> Bool {
        do {
            let remoteTasks = try await remote.fetchAll()
            let locals = try store.fetchAll()
            let localsByID = Dictionary(locals.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

            let incoming = remoteTasks.filter { remoteTask in
                guard let local = localsByID[remoteTask.id] else { return true }
                return ConflictResolver.resolve(local: local, remote: remoteTask) == .takeRemote
            }
            if !incoming.isEmpty {
                try store.upsert(incoming)
            }

            let remoteIDs = Set(remoteTasks.map(\.id))
            let deletedElsewhere = locals.map(\.id).filter { !remoteIDs.contains($0) }
            if !deletedElsewhere.isEmpty {
                try store.delete(ids: deletedElsewhere)
            }

            return true
        } catch {
            return false
        }
    }
}

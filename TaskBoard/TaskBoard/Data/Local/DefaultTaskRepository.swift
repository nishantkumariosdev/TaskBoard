//
//  DefaultTaskRepository.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class DefaultTaskRepository: TaskRepository {
    private let store: LocalTaskStore
    weak var syncCoordinator: (any SyncCoordinating)?
    
    init(store: LocalTaskStore) {
        self.store = store
    }
    
    func observeTasks() -> AsyncStream<[BoardTask]> {
        store.observe()
    }
    
    func load() throws {
        try store.publishCurrent()
    }
    
    func allTasks() throws -> [BoardTask] {
        try store.fetchAll()
    }
    
    func task(id: String) throws -> BoardTask? {
        try store.fetch(id: id)
    }
    
    func save(_ task: BoardTask) throws {
        try store.upsert([task.markedPending()])
        syncCoordinator?.requestSync()
    }
    
    func saveAll(_ tasks: [BoardTask]) throws {
        try store.upsert(tasks.map { $0.markedPending() })
        syncCoordinator?.requestSync()
    }
    
    func delete(id: String) throws {
        try store.markPendingDelete(id: id)
        syncCoordinator?.requestSync()
    }
    
    
}

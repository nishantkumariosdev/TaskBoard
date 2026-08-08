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
        try store.upsert([task])
        syncCoordinator?.push(task)
    }
    
    func saveAll(_ tasks: [BoardTask]) throws {
        try store.upsert(tasks)
        for task in tasks {
            syncCoordinator?.push(task)
        }
    }
    
    func delete(id: String) throws {
        try store.delete(ids: [id])
        syncCoordinator?.pushDelete(id: id)
    }
    
    
}

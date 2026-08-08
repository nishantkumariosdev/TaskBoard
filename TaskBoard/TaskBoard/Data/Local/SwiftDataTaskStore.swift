//
//  SwiftDataTaskStore.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataTaskStore: LocalTaskStore {
    private let context: ModelContext
    
    private var observers: [UUID: AsyncStream<[BoardTask]>.Continuation] = [:]
    
    init(container: ModelContainer) {
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
    }
    
    func observe() -> AsyncStream<[BoardTask]> {
        AsyncStream { continuation in
            let id = UUID()
            observers[id] = continuation
            
            continuation.yield(currentTasks())
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.observers[id] = nil
                }
            }
        }
    }
    
    func publishCurrent() throws {
        publish(try fetchAll())
    }
    
    func fetchAll() throws -> [BoardTask] {
        try fetchEntities()
            .filter { $0.syncStateRaw != SyncState.pendingDelete.rawValue }
            .map(TaskEntityMapper.toDomain)
            .sortedForBoard()
    }
    
    func fetchAllIncludingDeleted() throws -> [BoardTask] {
        try fetchEntities().map(TaskEntityMapper.toDomain)
    }
    
    func fetchPending() throws -> [BoardTask] {
        try fetchEntities()
            .map(TaskEntityMapper.toDomain)
            .filter(\.syncState.isPending)
            .sorted { $0.updatedAt < $1.updatedAt }
    }
    
    func fetch(id: String) throws -> BoardTask? {
        guard let entity = try entity(withId: id),
              entity.syncStateRaw != SyncState.pendingDelete.rawValue
        else { return nil }
        return TaskEntityMapper.toDomain(entity)
    }
    
    func upsert(_ tasks: [BoardTask]) throws {
        guard !tasks.isEmpty else { return }
        
        do {
            let existing = try fetchEntities().reduce(into: [String: TaskEntity]()) {
                $0[$1.id] = $1
            }
            
            for task in tasks {
                if let entity = existing[task.id] {
                    TaskEntityMapper.apply(task, to: entity)
                } else {
                    context.insert(TaskEntityMapper.toEntity(task))
                }
            }
            
            try commit()
        } catch let error as BoardError {
            throw error
        } catch {
            throw BoardError.persistenceFailed(reason: error.localizedDescription)
        }
    }
    
    func markPendingDelete(id: String) throws {
        guard let entity = try entity(withId: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        entity.syncStateRaw = SyncState.pendingDelete.rawValue
        try commit()
    }
    
    func markSynced(id: String) throws {
        guard let entity = try entity(withId: id) else { return }
        entity.syncStateRaw = SyncState.synced.rawValue
        try commit()
    }

    func hardDelete(ids: [String]) throws {
        guard !ids.isEmpty else { return }

        let targets = Set(ids)
        for entity in try fetchEntities() where targets.contains(entity.id) {
            context.delete(entity)
        }
        try commit()
    }
    
    private func currentTasks() -> [BoardTask] {
        (try? fetchAll()) ?? []
    }
    
    private func publish(_ tasks: [BoardTask]) {
        for continuation in observers.values {
            continuation.yield(tasks)
        }
    }
    
    private func fetchEntities() throws -> [TaskEntity] {
        do {
            return try context.fetch(FetchDescriptor<TaskEntity>())
        } catch {
            throw BoardError.loadFailed(reason: error.localizedDescription)
        }
    }
    
    private func entity(withId id: String) throws -> TaskEntity? {
        try fetchEntities().first { $0.id == id }
    }
    
    private func commit() throws {
        do {
            try context.save()
            publish(try fetchAll())
        } catch {
            context.rollback()
            throw BoardError.persistenceFailed(reason: error.localizedDescription)
        }
    }
}

extension Array where Element == BoardTask {
    func sortedForBoard() -> [BoardTask] {
        sorted {
            $0.status.sortOrder == $1.status.sortOrder
                ? $0.orderIndex < $1.orderIndex
                : $0.status.sortOrder < $1.status.sortOrder
        }
    }
}

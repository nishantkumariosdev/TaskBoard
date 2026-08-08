//
//  DefaultTaskUseCases.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
struct DefaultObserveTasksUseCase: ObserveTasksUseCase {
    let repository: TaskRepository
    
    func execute() -> AsyncStream<[BoardTask]> {
        repository.observeTasks()
    }
}

@MainActor
struct DefaultLoadBoardUseCase: LoadBoardUseCase {
    let repository: TaskRepository
    let syncCoordinator: SyncCoordinating
    
    func execute() throws {
        try repository.load()
        syncCoordinator.start()
    }
}

@MainActor
struct DefaultCreateTaskUseCase: CreateTaskUseCase {
    let repository: TaskRepository
    
    func execute(title: String, details: String, status: TaskStatus) throws -> BoardTask {
        let now = Date()
        let column = try repository.allTasks()
            .filter { $0.status == status }
            .sorted { $0.orderIndex < $1.orderIndex }
        let task = BoardTask(id: UUID().uuidString, title: title, details: details, status: status, createdAt: now, updatedAt: now, orderIndex: 0)
        
        try repository.saveAll(ColumnOrdering.renumbered(column, inserting: task, at: 0, updatedOn: now))
        return task
    }
}

@MainActor
struct DefaultUpdateTaskUseCase: UpdateTaskUseCase {
    let repository: TaskRepository
    
    func execute(id: String, title: String, details: String) throws -> BoardTask {
        guard let existing = try repository.task(id: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        
        var updated = existing
        updated.title = title
        updated.details = details
        
        guard updated.title != existing.title || updated.details != existing.details else {
            return existing
        }
        
        let touched = updated.touched(at: Date())
        try repository.save(touched)
        return touched
    }
}

@MainActor
struct DefaultDeleteTaskUseCase: DeleteTaskUseCase {
    let repository: TaskRepository
    
    func execute(id: String) throws {
        guard try repository.task(id: id) != nil else {
            throw BoardError.taskNotFound(id: id)
        }
        
        try repository.delete(id: id)
    }
}

@MainActor
struct DefaultMoveTaskUseCase: MoveTaskUseCase {
    let repository: TaskRepository

    func execute(id: String, to status: TaskStatus, position: Int?) throws -> BoardTask {
        guard let existing = try repository.task(id: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        
        let now = Date()
        let siblings = try repository.allTasks()
            .filter { $0.status == status && $0.id != id }
            .sorted { $0.orderIndex < $1.orderIndex }
        let slot = max(0, min(position ?? siblings.count, siblings.count))
        
        var moved = existing
        moved.status = status
        
        let renumbered = ColumnOrdering.renumbered(siblings, inserting: moved, at: slot, updatedOn: now)
        try repository.saveAll(renumbered)
        guard let result = renumbered.first(where: { $0.id == id }) else {
            throw BoardError.taskNotFound(id: id)
        }
        return result
    }
}

private enum ColumnOrdering {
    static func renumbered(_ column: [BoardTask], inserting task: BoardTask, at slot: Int, updatedOn date: Date) -> [BoardTask] {
        var tasks = column
        tasks.insert(task, at: max(0, min(slot, tasks.count)))
        
        return tasks.enumerated().map { index, existing in
            var copy = existing
            copy.orderIndex = index
            return copy.touched(at: date)
        }
    }
}

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
    
    func execute(title: String, details: String, status: TaskStatus, subtasks: [SubTask]) throws -> BoardTask {
        let now = Date()
        let column = try repository.allTasks()
            .filter { $0.status == status && !$0.isArchived }
            .sorted { $0.orderIndex < $1.orderIndex }
        let task = BoardTask(id: UUID().uuidString, title: title, details: details, status: status, createdAt: now, updatedAt: now, orderIndex: 0, subtasks: subtasks)
        
        try repository.saveAll(ColumnOrdering.renumbered(column, inserting: task, at: 0, updatedOn: now))
        return task
    }
}

@MainActor
struct DefaultUpdateTaskUseCase: UpdateTaskUseCase {
    let repository: TaskRepository
    
    func execute(id: String, title: String, details: String, subtasks: [SubTask]) throws -> BoardTask {
        guard let existing = try repository.task(id: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        
        var updated = existing
        updated.title = title
        updated.details = details
        updated.subtasks = subtasks
        
        guard updated.title != existing.title || updated.details != existing.details || updated.subtasks != existing.subtasks else {
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
            .filter { $0.status == status && $0.id != id && !$0.isArchived }
            .sorted { $0.orderIndex < $1.orderIndex }
        let slot = max(0, min(position ?? siblings.count, siblings.count))
        
        var moved = existing
        moved.status = status
        
        var updates = ColumnOrdering.renumbered(siblings, inserting: moved, at: slot, updatedOn: now)
        if existing.status != status {
            let source = try repository.allTasks()
                .filter{ $0.status == existing.status && $0.id != id && !$0.isArchived }
                .sorted { $0.orderIndex < $1.orderIndex }
            updates += ColumnOrdering.reorderAfterArchive(source, updatedOn: now)
        }
        
        
        try repository.saveAll(updates)
        guard let result = updates.first(where: { $0.id == id }) else {
            throw BoardError.taskNotFound(id: id)
        }
        return result
    }
}

@MainActor
struct DefaultArchiveTaskUseCase: ArchiveTaskUseCase {
    let repository: TaskRepository

    func execute(id: String) throws -> BoardTask {
        guard let existing = try repository.task(id: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        
        guard !existing.isArchived else { return existing }
        let now = Date()
        let archived = existing.archivedTask(true, at: now)
        
        let siblings = try repository.allTasks()
            .filter { $0.status == existing.status && $0.id != id && !$0.isArchived }
            .sorted { $0.orderIndex < $1.orderIndex }
        
        try repository.saveAll([archived] + ColumnOrdering.reorderAfterArchive(siblings, updatedOn: now))
        return archived
    }
}

@MainActor
struct DefaultRestoreTaskUseCase: RestoreTaskUseCase {
    let repository: TaskRepository

    func execute(id: String) throws -> BoardTask {
        guard let existing = try repository.task(id: id) else {
            throw BoardError.taskNotFound(id: id)
        }
        
        guard existing.isArchived else { return existing }
        
        let now = Date()
        let restored = existing.archivedTask(false, at: now)
        let siblings = try repository.allTasks()
            .filter { $0.status == existing.status && $0.id != id && !$0.isArchived }
            .sorted { $0.orderIndex < $1.orderIndex }
        
        let renumbered = ColumnOrdering.renumbered(siblings, inserting: restored, at: siblings.count, updatedOn: now)
        try repository.saveAll(renumbered)
        
        guard let result = renumbered.first(where: { $0.id == id }) else {
            throw BoardError.taskNotFound(id: id)
        }
        return result
    }
}

@MainActor
struct DefaultToggleSubtaskUseCase: ToggleSubtaskUseCase {
    let repository: TaskRepository

    func execute(subtaskID: String, in taskID: String) throws -> BoardTask {
        try repository.updatingSubtasks(of: taskID) { subtasks in
            guard let index = subtasks.firstIndex(where: { $0.id == subtaskID }) else {
                throw BoardError.taskNotFound(id: subtaskID)
            }
            subtasks[index] = subtasks[index].toggled()
        }
    }
}

@MainActor
struct DefaultRemoveSubtaskUseCase: RemoveSubtaskUseCase {
    let repository: TaskRepository

    func execute(subtaskID: String, from taskID: String) throws -> BoardTask {
        try repository.updatingSubtasks(of: taskID) { subtasks in
            guard subtasks.contains(where: { $0.id == subtaskID }) else {
                throw BoardError.taskNotFound(id: subtaskID)
            }
            subtasks.removeAll { $0.id == subtaskID }
        }
    }
}

private extension TaskRepository {
    func updatingSubtasks(of taskID: String, _ change: (inout [SubTask]) throws -> Void) throws -> BoardTask {
        guard let existing = try task(id: taskID) else {
            throw BoardError.taskNotFound(id: taskID)
        }

        var subtasks = existing.subtasks
        try change(&subtasks)

        var updated = existing
        updated.subtasks = subtasks
        let touched = updated.touched(at: Date())

        try save(touched)
        return touched
    }
}

private enum ColumnOrdering {
    static func renumbered(_ column: [BoardTask], inserting task: BoardTask, at slot: Int, updatedOn date: Date) -> [BoardTask] {
        var tasks = column
        tasks.insert(task, at: max(0, min(slot, tasks.count)))
        
        return tasks.enumerated().compactMap { index, existing in
            guard existing.id == task.id || existing.orderIndex != index else {
                return nil
            }
            var copy = existing
            copy.orderIndex = index
            return copy.touched(at: date)
        }
    }
    
    static func reorderAfterArchive(_ column: [BoardTask], updatedOn date: Date) -> [BoardTask] {
        column.enumerated().compactMap { index, existing in
            guard existing.orderIndex != index else { return nil }
            
            var copy = existing
            copy.orderIndex = index
            return copy.touched(at: date)
        }
    }
}

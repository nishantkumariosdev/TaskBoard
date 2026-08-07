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
    
    func execute() throws {
        try repository.load()
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

private enum ColumnOrdering {
    static func renumbered(_ column: [BoardTask], inserting task: BoardTask, at slot: Int, updatedOn date: Date) -> [BoardTask] {
        var tasks = column
        tasks.insert(task, at: max(0, min(slot, tasks.count)))
        
        return tasks.enumerated().map { index, existing in
            var copy = existing
            copy.orderIndex = index
            return copy.id == task.id ? copy.touched(at: date) : copy
        }
    }
}

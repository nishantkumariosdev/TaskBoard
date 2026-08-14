//
//  TaskUseCases.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
protocol ObserveTasksUseCase {
    func execute() -> AsyncStream<[BoardTask]>
}

@MainActor
protocol LoadBoardUseCase {
    func execute() throws
}

@MainActor
protocol CreateTaskUseCase {
    @discardableResult
    func execute(title: String, details: String, status: TaskStatus, subtasks: [SubTask]) throws -> BoardTask
}

@MainActor
protocol UpdateTaskUseCase {
    @discardableResult
    func execute(id: String, title: String, details: String, subtasks: [SubTask]) throws -> BoardTask
}

@MainActor
protocol DeleteTaskUseCase {
    func execute(id: String) throws
}

@MainActor
protocol MoveTaskUseCase {
    @discardableResult
    func execute(id: String, to status: TaskStatus, position: Int?) throws -> BoardTask
}

@MainActor
protocol ArchiveTaskUseCase {
    @discardableResult
    func execute(id: String) throws -> BoardTask
}

@MainActor
protocol RestoreTaskUseCase {
    @discardableResult
    func execute(id: String) throws -> BoardTask
}

@MainActor
protocol ToggleSubtaskUseCase {
    @discardableResult
    func execute(subtaskID: String, in taskID: String) throws -> BoardTask
}

@MainActor
protocol RemoveSubtaskUseCase {
    @discardableResult
    func execute(subtaskID: String, from taskID: String) throws -> BoardTask
}

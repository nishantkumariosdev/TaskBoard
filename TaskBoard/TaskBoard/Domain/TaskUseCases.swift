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
    func execute(title: String, details: String, status: TaskStatus) throws -> BoardTask
}

@MainActor
protocol UpdateTaskUseCase {
    @discardableResult
    func execute(id: String, title: String, details: String) throws -> BoardTask
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

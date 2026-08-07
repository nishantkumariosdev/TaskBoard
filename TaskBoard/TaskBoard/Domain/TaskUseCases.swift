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

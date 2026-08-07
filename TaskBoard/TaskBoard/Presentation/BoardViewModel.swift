//
//  BoardViewModel.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

@MainActor
@Observable
final class BoardViewModel {
    struct Column: Identifiable {
        let status: TaskStatus
        var tasks: [BoardTask]
        var id: TaskStatus { status }
    }
    
    enum LoadState: Equatable {
        case loading
        case ready
        case failure(message: String)
    }
    
    private(set) var loadState: LoadState = .loading
    private(set) var columns: [Column] = TaskStatus.allCases.map {
        Column(status: $0, tasks: [])
    }
    private(set) var collapsedStatuses: Set<TaskStatus> = []
    
    var isBoardEmpty: Bool {
        columns.allSatisfy(\.tasks.isEmpty)
    }
    
    func onAppear() {
        let task1 = BoardTask(id: "1", title: "Task 1", description: "Hello", status: .todo, createdAt: .now, updatedAt: .now)
        let task2 = BoardTask(id: "2", title: "Task 2", description: "Hello", status: .inProgress, createdAt: .now, updatedAt: .now)
        let task3 = BoardTask(id: "3", title: "Task 3", description: "Hello", status: .inProgress, createdAt: .now, updatedAt: .now)
        let allTasks = [task1, task2, task3]
        loadState = .ready
        apply(allTasks)
    }
    
    private func apply(_ tasks: [BoardTask]) {
        columns = TaskStatus.allCases.map { status in
            Column(
                status: status,
                tasks: tasks
                    .filter { $0.status == status }
            )
        }
    }
}

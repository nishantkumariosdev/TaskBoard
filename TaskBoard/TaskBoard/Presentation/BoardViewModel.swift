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
        case failed(message: String)
    }
    
    private(set) var loadState: LoadState = .loading
    private(set) var columns: [Column] = TaskStatus.allCases.map {
        Column(status: $0, tasks: [])
    }
    private(set) var collapsedStatuses: Set<TaskStatus> = []
    
    var isBoardEmpty: Bool {
        columns.allSatisfy(\.tasks.isEmpty)
    }
    
    private let observeTasks: ObserveTasksUseCase
    private let loadBoard: LoadBoardUseCase
    private let createTask: CreateTaskUseCase
    
    init(observeTasks: ObserveTasksUseCase, loadBoard: LoadBoardUseCase, createTask: CreateTaskUseCase) {
        self.observeTasks = observeTasks
        self.loadBoard = loadBoard
        self.createTask = createTask
    }
    
    func start() async {
        load()
        
        for await tasks in observeTasks.execute() {
            apply(tasks)
        }
    }
    
    func toggleCollapse(_ status: TaskStatus) {
        if collapsedStatuses.contains(status) {
            collapsedStatuses.remove(status)
        } else {
            collapsedStatuses.insert(status)
        }
    }
    
    private func load() {
        loadState = .loading
        
        do {
            try loadBoard.execute()
            loadState = .ready
        } catch {
            loadState = .failed(message: (error as? BoardError)?.localizedDescription ?? error.localizedDescription)
        }
    }
    
    private func apply(_ tasks: [BoardTask]) {
        columns = TaskStatus.allCases.map { status in
            Column(
                status: status,
                tasks: tasks
                    .filter { $0.status == status }
                    .sorted { $0.orderIndex < $1.orderIndex }
            )
        }
        
        if case .failed = loadState { loadState = .ready }
    }
}

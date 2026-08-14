//
//  ArchiveViewModel.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 14/08/26.
//

import Foundation

@MainActor
protocol ArchiveViewModelFactory {
    func makeArchiveViewModel() -> ArchiveViewModel
}

@MainActor
@Observable
final class ArchiveViewModel {
    private(set) var tasks: [BoardTask] = []
    var banner: String?
    
    private let observeTasks: ObserveTasksUseCase
    private let deleteTask: DeleteTaskUseCase
    private let restoreTask: RestoreTaskUseCase
    
    var isEmpty: Bool { tasks.isEmpty }
    
    init(observeTasks: ObserveTasksUseCase, deleteTask: DeleteTaskUseCase, restoreTask: RestoreTaskUseCase) {
        self.observeTasks = observeTasks
        self.deleteTask = deleteTask
        self.restoreTask = restoreTask
    }
    
    func start() async {
        for await tasks in observeTasks.execute() {
            apply(tasks)
        }
    }
    
    func delete(id: String) {
        do {
            try self.deleteTask.execute(id: id)
            banner = nil
        } catch {
            banner = message(for: error)
        }
    }
    
    func restore(id: String) {
        do {
            try self.restoreTask.execute(id: id)
            banner = nil
        } catch {
            banner = message(for: error)
        }
    }
    
    private func apply(_ tasks: [BoardTask]) {
        self.tasks = tasks.filter(\.isArchived)
    }
    
    private func message(for error: Error) -> String {
        (error as? BoardError)?.localizedDescription ?? error.localizedDescription
    }
}

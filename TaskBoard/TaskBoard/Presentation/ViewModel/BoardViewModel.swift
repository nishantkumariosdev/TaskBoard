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
    private(set) var syncStatus = SyncStatus()
    
    var isBoardEmpty: Bool {
        columns.allSatisfy(\.tasks.isEmpty)
    }
    
    private let observeTasks: ObserveTasksUseCase
    private let loadBoard: LoadBoardUseCase
    private let deleteTask: DeleteTaskUseCase
    private let moveTask: MoveTaskUseCase
    private let syncCoordinator: any SyncCoordinating
    
    init(observeTasks: ObserveTasksUseCase, loadBoard: LoadBoardUseCase, deleteTask: DeleteTaskUseCase, moveTask: MoveTaskUseCase, syncCoordinator: any SyncCoordinating) {
        self.observeTasks = observeTasks
        self.loadBoard = loadBoard
        self.deleteTask = deleteTask
        self.moveTask = moveTask
        self.syncCoordinator = syncCoordinator
    }
    
    func start() async {
        load()
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor [self] in
                for await tasks in observeTasks.execute() {
                    apply(tasks)
                }
            }
            group.addTask { @MainActor [self] in
                for await status in syncCoordinator.observeStatus() {
                    syncStatus = status
                }
            }
        }
    }
    
    func refresh() async {
        await syncCoordinator.syncNow()
    }
    
    func delete(id: String) {
        do {
            try self.deleteTask.execute(id: id)
        } catch {
            print("\(message(for: error))")
        }
    }
    
    func move(id: String, to status: TaskStatus, position: Int?) {
        do {
            try self.moveTask.execute(id: id, to: status, position: position)
        } catch {
            print("\(message(for: error))")
        }
    }
    
    func handleDrop(taskId: String, into status: TaskStatus, at visibleIndex: Int) {
        guard let task = task(withId: taskId) else {
            print("\(BoardError.taskNotFound(id: taskId).localizedDescription))")
            return
        }
        
        var position = visibleIndex
        if task.status == status, let currentIndex = tasks(in: status).firstIndex(where: { $0.id == taskId }) {
            if currentIndex == visibleIndex || currentIndex == visibleIndex - 1 { return }
            if currentIndex < visibleIndex {
                position -= 1
            }
        }
        move(id: taskId, to: status, position: position)
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
            loadState = .failed(message: message(for: error))
        }
    }
    
    private func task(withId id: String) -> BoardTask? {
        columns.lazy.flatMap(\.tasks).first { $0.id == id }
    }
    
    private func tasks(in status: TaskStatus) -> [BoardTask] {
        columns.first { $0.status == status }?.tasks ?? []
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
    
    private func message(for error: Error) -> String {
        (error as? BoardError)?.localizedDescription ?? error.localizedDescription
    }
}

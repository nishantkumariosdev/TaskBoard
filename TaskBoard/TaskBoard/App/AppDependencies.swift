//
//  AppDependencies.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

@MainActor
final class AppDependencies: TaskEditorViewModelFactory {
    
    private let store: LocalTaskStore
    private let repository: DefaultTaskRepository
    private let syncCoordinator: any SyncCoordinating
    
    init() {
        let storage = LocalTaskStoreContainer.forApp()
        let store = SwiftDataTaskStore(container: storage.modelContainer)
        
        self.store = store
        self.repository = DefaultTaskRepository(store: store)
        
        if let databaseURL = AppConfiguration.databaseURL {
            let remote = FirebaseDatabaseTaskDataSource(
                databaseURL: databaseURL,
                boardNode: AppConfiguration.boardNode,
                client: URLSessionHTTPClient()
            )
            let engine = SyncEngine(store: store, remote: remote)
            self.syncCoordinator = FirebaseSyncCoordinator(engine: engine, network: NetworkMonitor())
        } else {
            self.syncCoordinator = LocalOnlySyncCoordinator()
        }
        repository.syncCoordinator = syncCoordinator
    }
    
    func applicationBecameActive() {
        Task { await syncCoordinator.syncNow() }
    }
    
    private var observerTasksUseCase: ObserveTasksUseCase {
        DefaultObserveTasksUseCase(repository: repository)
    }
    
    private var loadBoardUsecase: LoadBoardUseCase {
        DefaultLoadBoardUseCase(repository: repository, syncCoordinator: syncCoordinator)
    }
    
    private var createTaskUseCase: CreateTaskUseCase {
        DefaultCreateTaskUseCase(repository: repository)
    }
    
    private var updateTaskUseCase: UpdateTaskUseCase {
        DefaultUpdateTaskUseCase(repository: repository)
    }
    
    private var deleteTaskUseCase: DeleteTaskUseCase {
        DefaultDeleteTaskUseCase(repository: repository)
    }
    
    private var moveTaskUseCasse: MoveTaskUseCase {
        DefaultMoveTaskUseCase(repository: repository)
    }
    
    func makeBoardViewModel() -> BoardViewModel {
        let viewModel = BoardViewModel(observeTasks: observerTasksUseCase, loadBoard: loadBoardUsecase, deleteTask: deleteTaskUseCase, moveTask: moveTaskUseCasse, syncCoordinator: syncCoordinator)
        return viewModel
    }
    
    func makeEditorViewModel(mode: TaskEditorViewModel.Mode) -> TaskEditorViewModel {
        TaskEditorViewModel(mode: mode, createTask: createTaskUseCase, updateTask: updateTaskUseCase, moveTask: moveTaskUseCasse)
    }
}

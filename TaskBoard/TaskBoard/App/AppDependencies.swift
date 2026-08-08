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
    
    init() {
        let storage = LocalTaskStoreContainer.forApp()
        let store = SwiftDataTaskStore(container: storage.modelContainer)
        
        self.store = store
        self.repository = DefaultTaskRepository(store: store)
    }
    
    private var observerTasksUseCase: ObserveTasksUseCase {
        DefaultObserveTasksUseCase(repository: repository)
    }
    
    private var loadBoardUsecase: LoadBoardUseCase {
        DefaultLoadBoardUseCase(repository: repository)
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
        let viewModel = BoardViewModel(observeTasks: observerTasksUseCase, loadBoard: loadBoardUsecase, deleteTask: deleteTaskUseCase, moveTask: moveTaskUseCasse)
        return viewModel
    }
    
    func makeEditorViewModel(mode: TaskEditorViewModel.Mode) -> TaskEditorViewModel {
        TaskEditorViewModel(mode: mode, createTask: createTaskUseCase, updateTask: updateTaskUseCase, moveTask: moveTaskUseCasse)
    }
}

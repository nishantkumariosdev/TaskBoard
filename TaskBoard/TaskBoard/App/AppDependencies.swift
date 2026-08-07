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
    
    func makeBoardViewModel() -> BoardViewModel {
        let viewModel = BoardViewModel(observeTasks: observerTasksUseCase, loadBoard: loadBoardUsecase, createTask: createTaskUseCase)
        return viewModel
    }
    
    func makeEditorViewModel(mode: TaskEditorViewModel.Mode) -> TaskEditorViewModel {
        TaskEditorViewModel(mode: mode, createTask: createTaskUseCase)
    }
}

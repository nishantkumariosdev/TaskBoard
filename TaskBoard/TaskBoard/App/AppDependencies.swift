//
//  AppDependencies.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

@MainActor
final class AppDependencies: TaskEditorViewModelFactory {
    func makeBoardViewModel() -> BoardViewModel {
        let viewModel = BoardViewModel()
        return viewModel
    }
    
    func makeEditorViewModel(mode: TaskEditorViewModel.Mode) -> TaskEditorViewModel {
        TaskEditorViewModel(mode: mode)
    }
}

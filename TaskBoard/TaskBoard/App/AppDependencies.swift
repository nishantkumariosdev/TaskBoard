//
//  AppDependencies.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

@MainActor
final class AppDependencies {
    func makeBoardViewModel() -> BoardViewModel {
        let viewModel = BoardViewModel()
        return viewModel
    }
}

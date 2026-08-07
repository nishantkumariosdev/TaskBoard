//
//  TaskBoardApp.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import SwiftUI

@main
struct TaskBoardApp: App {
    
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            BoardView(viewModel: dependencies.makeBoardViewModel(), editorFactory: dependencies)
        }
    }
}

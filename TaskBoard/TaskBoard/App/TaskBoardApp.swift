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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            BoardView(viewModel: dependencies.makeBoardViewModel(), editorFactory: dependencies, archiveFactory: dependencies)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                dependencies.applicationBecameActive()
            }
        }
    }
}

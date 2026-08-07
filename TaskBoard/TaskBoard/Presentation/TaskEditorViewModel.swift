//
//  TaskEditorViewModel.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

@MainActor
protocol TaskEditorViewModelFactory {
    func makeEditorViewModel(mode: TaskEditorViewModel.Mode) -> TaskEditorViewModel
}

@MainActor
@Observable
final class TaskEditorViewModel {
    enum Mode: Identifiable {
        case create(status: TaskStatus)
        case edit(task: BoardTask)
        
        var id: String {
            switch self {
            case .create(let status): return "create-\(status.rawValue)"
            case .edit(let task): return "edit-\(task.id)"
            }
        }
    }
    
    var title: String
    var description: String
    var status: TaskStatus
    
    let mode: Mode
    
    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    var screenTitle: String {
        isEditing ? "Edit Task" : "New Task"
    }
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .create(let status):
            self.title = ""
            self.description = ""
            self.status = status
        case .edit(let task):
            self.title = task.title
            self.description = task.description
            self.status = task.status
        }
    }
    
    func save() -> Bool {
        return true
    }
}

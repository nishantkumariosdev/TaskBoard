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
    var details: String
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
    
    var createdAt: Date? {
        if case .edit(let task) = mode {
            return task.createdAt
        }
        return nil
    }
    
    var updatedAt: Date? {
        if case .edit(let task) = mode {
            return task.updatedAt
        }
        return nil
    }
    
    var hasBeenEdited: Bool {
        if case .edit(let task) = mode {
            return task.hasBeenEdited
        }
        return false
    }
    
    private let createTask: CreateTaskUseCase
    private let updateTask: UpdateTaskUseCase
    private let moveTask: MoveTaskUseCase
    
    init(mode: Mode, createTask: CreateTaskUseCase, updateTask: UpdateTaskUseCase, moveTask: MoveTaskUseCase) {
        self.mode = mode
        self.createTask = createTask
        self.updateTask = updateTask
        self.moveTask = moveTask
        
        switch mode {
        case .create(let status):
            self.title = ""
            self.details = ""
            self.status = status
        case .edit(let task):
            self.title = task.title
            self.details = task.details
            self.status = task.status
        }
    }
    
    func save() -> Bool {
        do {
            switch mode {
            case .create:
                try createTask.execute(title: title, details: details, status: status)
            case .edit(let task):
                try updateTask.execute(id: task.id, title: title, details: details)
                
                if status != task.status {
                    try moveTask.execute(id: task.id, to: status, position: 0)
                }
            }
            return true
        } catch {
            return false
        }
    }
}

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
    var subtasks: [SubTask]
    var newSubtaskTitle: String = ""
    
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
    
    var canAddSubtask: Bool {
        !newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var completedSubtaskCount: Int {
        subtasks.lazy.filter(\.isCompleted).count
    }
    
    var activity: [ActivityEntry] {
        guard case .edit(let task) = mode else { return [] }
        return task.activity.reversed()
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
            self.subtasks = []
        case .edit(let task):
            self.title = task.title
            self.details = task.details
            self.status = task.status
            self.subtasks = task.subtasks
        }
    }
    
    func save() -> Bool {
        do {
            switch mode {
            case .create:
                try createTask.execute(title: title, details: details, status: status, subtasks: subtasks)
            case .edit(let task):
                try updateTask.execute(id: task.id, title: title, details: details, subtasks: subtasks)
                
                if status != task.status {
                    try moveTask.execute(id: task.id, to: status, position: 0)
                }
            }
            return true
        } catch {
            return false
        }
    }
    
    func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        subtasks.append(SubTask(title: trimmed))
        newSubtaskTitle = ""
    }

    func toggleSubtask(id: String) {
        guard let index = subtasks.firstIndex(where: { $0.id == id }) else { return }
        subtasks[index] = subtasks[index].toggled()
    }

    func removeSubtask(id: String) {
        subtasks.removeAll { $0.id == id }
    }

    func removeSubtasks(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }
}

//
//  BoardTask.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

struct BoardTask: Identifiable {
    let id: String
    var title: String
    var details: String
    var status: TaskStatus
    let createdAt: Date
    var updatedAt: Date
    var orderIndex: Int
    var syncState: SyncState
    var isArchived: Bool
    var subtasks: [SubTask]
    var activity: [ActivityEntry]
    
    init(id: String, title: String, details: String, status: TaskStatus = .todo, createdAt: Date, updatedAt: Date, orderIndex: Int, syncState: SyncState = .pendingSave, isArchived: Bool = false, subtasks: [SubTask] = [], activity: [ActivityEntry] = []) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderIndex = orderIndex
        self.syncState = syncState
        self.isArchived = isArchived
        self.subtasks = subtasks
        self.activity = activity
    }
}

extension BoardTask {
    func touched(at date: Date) -> BoardTask {
        var copy = self
        copy.updatedAt = date
        return copy
    }
    
    func markedPending() -> BoardTask {
        var copy = self
        copy.syncState = .pendingSave
        return copy
    }
    
    func markedSynced() -> BoardTask {
        var copy = self
        copy.syncState = .synced
        return copy
    }
    
    var hasBeenEdited: Bool {
        updatedAt > createdAt
    }
    
    func archivedTask(_ archived: Bool, at date: Date) -> BoardTask {
        var copy = self
        copy.isArchived = archived
        copy.updatedAt = date
        return copy
    }
    
    var hasSubtasks: Bool {
        !subtasks.isEmpty
    }
    
    var completedSubtaskCount: Int {
        subtasks.lazy.filter(\.isCompleted).count
    }

    var allSubtasksCompleted: Bool {
        hasSubtasks && completedSubtaskCount == subtasks.count
    }
    
    func logging(_ kind: ActivityKind, subject: String? = nil, from: TaskStatus? = nil, to: TaskStatus? = nil, at date: Date) -> BoardTask {
        var copy = self
        copy.activity.append(
            ActivityEntry(kind: kind, timestamp: date, subject: subject, from: from, to: to)
        )

        let overflow = copy.activity.count - ActivityEntry.historyLimit
        if overflow > 0 {
            copy.activity.removeFirst(overflow)
        }
        return copy
    }
}

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
    
    init(id: String, title: String, details: String, status: TaskStatus = .todo, createdAt: Date, updatedAt: Date, orderIndex: Int, syncState: SyncState = .pendingSave) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderIndex = orderIndex
        self.syncState = syncState
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
}

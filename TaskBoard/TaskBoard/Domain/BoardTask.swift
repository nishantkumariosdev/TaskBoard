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
    
    init(id: String, title: String, details: String, status: TaskStatus, createdAt: Date, updatedAt: Date, orderIndex: Int) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderIndex = orderIndex
    }
}

extension BoardTask {
    func touched(at date: Date) -> BoardTask {
        var copy = self
        copy.updatedAt = date
        return copy
    }
    
    var hasBeenEdited: Bool {
        updatedAt > createdAt
    }
}

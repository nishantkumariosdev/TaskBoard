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
    var description: String
    var status: TaskStatus
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String, title: String, description: String, status: TaskStatus, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

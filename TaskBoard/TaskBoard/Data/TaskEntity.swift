//
//  TaskEntity.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import SwiftData

@Model
final class TaskEntity {
    
    @Attribute(.unique) var id: String
    var title: String
    var details: String
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int
    var syncStateRaw: String
    var isArchived: Bool = false
    var subtasks: [SubTask]
    
    init(id: String, title: String, details: String, statusRaw: String, createdAt: Date, updatedAt: Date, orderIndex: Int, syncStateRaw: String, isArchived: Bool = false, subtasks: [SubTask] = []) {
        self.id = id
        self.title = title
        self.details = details
        self.statusRaw = statusRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderIndex = orderIndex
        self.syncStateRaw = syncStateRaw
        self.isArchived = isArchived
        self.subtasks = subtasks
    }
}

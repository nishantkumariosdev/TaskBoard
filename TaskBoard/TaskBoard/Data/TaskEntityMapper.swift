//
//  TaskEntityMapper.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum TaskEntityMapper {
    static func toDomain(_ entity: TaskEntity) -> BoardTask {
        BoardTask(
            id: entity.id,
            title: entity.title,
            details: entity.details,
            status: TaskStatus(rawValue: entity.statusRaw) ?? .todo,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            orderIndex: entity.orderIndex,
            syncState: SyncState(rawValue: entity.syncStateRaw) ?? .pendingSave,
            isArchived: entity.isArchived,
            subtasks: entity.subtasks,
            activity: entity.activity
        )
    }
    
    static func toEntity(_ task: BoardTask) -> TaskEntity {
        TaskEntity(id: task.id, title: task.title, details: task.details, statusRaw: task.status.rawValue, createdAt: task.createdAt, updatedAt: task.updatedAt, orderIndex: task.orderIndex, syncStateRaw: task.syncState.rawValue, isArchived: task.isArchived, subtasks: task.subtasks, activity: task.activity)
    }
    
    static func apply(_ task: BoardTask, to entity: TaskEntity) {
        entity.title = task.title
        entity.details = task.details
        entity.statusRaw = task.status.rawValue
        entity.updatedAt = task.updatedAt
        entity.orderIndex = task.orderIndex
        entity.syncStateRaw = task.syncState.rawValue
        entity.isArchived = task.isArchived
        entity.subtasks = task.subtasks
        entity.activity = task.activity
    }
}

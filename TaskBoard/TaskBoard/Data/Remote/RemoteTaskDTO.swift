//
//  RemoteTaskDTO.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

struct RemoteTaskDTO: Codable, Sendable {

    let id: String
    let title: String
    let details: String
    let status: String
    let orderIndex: Int
    let createdAt: Double
    let updatedAt: Double
    let isArchived: Bool
    let subtasks: [RemoteSubTaskDTO]
}

struct RemoteSubTaskDTO: Codable, Sendable {
    let id: String
    let title: String
    let isCompleted: Bool
    let createdAt: Double
    
    init(_ subTask: SubTask) {
        self.id = subTask.id
        self.title = subTask.title
        self.isCompleted = subTask.isCompleted
        self.createdAt = subTask.createdAt.millisecondsSince1970
    }
    
    func toDomain() -> SubTask {
        SubTask(id: id, title: title, isCompleted: isCompleted, createdAt: Date(millisecondsSince1970: createdAt))
    }
}

extension RemoteTaskDTO {

    init(_ task: BoardTask) {
        self.id = task.id
        self.title = task.title
        self.details = task.details
        self.status = task.status.rawValue
        self.orderIndex = task.orderIndex
        self.createdAt = task.createdAt.millisecondsSince1970
        self.updatedAt = task.updatedAt.millisecondsSince1970
        self.isArchived = task.isArchived
        self.subtasks = task.subtasks.map(RemoteSubTaskDTO.init)
    }

    func toDomain() -> BoardTask {
        BoardTask(
            id: id,
            title: title,
            details: details,
            status: TaskStatus(rawValue: status) ?? .todo,
            createdAt: Date(millisecondsSince1970: createdAt),
            updatedAt: Date(millisecondsSince1970: updatedAt),
            orderIndex: orderIndex,
            isArchived: isArchived,
            subtasks: subtasks.map { $0.toDomain() }
        )
    }
}

private extension Date {

    var millisecondsSince1970: Double {
        timeIntervalSince1970 * 1000
    }

    init(millisecondsSince1970: Double) {
        self.init(timeIntervalSince1970: millisecondsSince1970 / 1000)
    }
}


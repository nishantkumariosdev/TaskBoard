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
    let isArchived: Bool?
    let subtasks: [RemoteSubTaskDTO]?
    let activity: [RemoteActivityDTO]?
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

struct RemoteActivityDTO: Codable, Sendable {
    let id: String
    let kind: String
    let timestamp: Double
    let subject: String?
    let from: String?
    let to: String?
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
        self.activity = task.activity.map(RemoteActivityDTO.init)
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
            isArchived: isArchived ?? false,
            subtasks: (subtasks ?? []).map { $0.toDomain() },
            activity: (activity ?? []).compactMap { $0.toDomain() }
        )
    }
}

extension RemoteActivityDTO {

    init(_ entry: ActivityEntry) {
        self.id = entry.id
        self.kind = entry.kind.rawValue
        self.timestamp = entry.timestamp.millisecondsSince1970
        self.subject = entry.subject
        self.from = entry.from?.rawValue
        self.to = entry.to?.rawValue
    }

    func toDomain() -> ActivityEntry? {
        guard let kind = ActivityKind(rawValue: kind) else { return nil }

        return ActivityEntry(
            id: id,
            kind: kind,
            timestamp: Date(millisecondsSince1970: timestamp),
            subject: subject,
            from: from.flatMap(TaskStatus.init(rawValue:)),
            to: to.flatMap(TaskStatus.init(rawValue:))
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


//
//  ActivityEntry.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 14/08/26.
//

import Foundation

enum ActivityKind: String, Codable, Sendable {
    case created
    case edited
    case archived
    case restored
    case moved
    case subtaskAdded
    case subtaskCompleted
    case subtaskReopened
    case subtaskRemoved
}

struct ActivityEntry: Identifiable, Equatable, Codable, Sendable {
    static let historyLimit = 50

    let id: String
    let kind: ActivityKind
    let timestamp: Date
    let subject: String?
    let from: TaskStatus?
    let to: TaskStatus?

    init(id: String = UUID().uuidString, kind: ActivityKind, timestamp: Date, subject: String? = nil, from: TaskStatus? = nil, to: TaskStatus? = nil) {
        self.id = id
        self.kind = kind
        self.timestamp = timestamp
        self.subject = subject
        self.from = from
        self.to = to
    }
}

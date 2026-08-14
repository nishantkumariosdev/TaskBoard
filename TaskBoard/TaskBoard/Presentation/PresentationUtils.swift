//
//  PresentationUtils.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

extension TaskStatus {
    var displayName: String {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        }
    }
    
    var systemImage: String {
        switch self {
        case .todo: return "tray"
        case .inProgress: return "clock"
        case .done: return "checkmark.circle"
        }
    }
    
    var tint: Color {
        switch self {
        case .todo: return .blue
        case .inProgress: return .orange
        case .done: return .green
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .todo: return "Nothing in To Do"
        case .inProgress: return "Nothing InProgress"
        case .done: return "Nothing completed"
        }
    }
}

extension ActivityEntry {
    var summary: String {
        switch kind {
        case .created:
            return "Task created"
        case .edited:
            return "Task edited"
        case .moved:
            guard let from, let to else { return "Moved to another section" }
            return "Moved from \(from.displayName) to \(to.displayName)"
        case .archived:
            return "Archived"
        case .restored:
            return "Restored to Board"
        case .subtaskAdded:
            return describe("Subtask added")
        case .subtaskCompleted:
            return describe("Subtask completed")
        case .subtaskReopened:
            return describe("Subtask reopened")
        case .subtaskRemoved:
            return describe("Subtask removed")
        }
    }

    var systemImage: String {
        switch kind {
        case .created: return "sparkles"
        case .edited: return "pencil"
        case .moved: return "arrow.left.arrow.right"
        case .archived: return "archivebox"
        case .restored: return "arrow.uturn.backward"
        case .subtaskAdded: return "plus.circle"
        case .subtaskCompleted: return "checkmark.circle"
        case .subtaskReopened: return "circle"
        case .subtaskRemoved: return "minus.circle"
        }
    }

    var tint: Color {
        switch kind {
        case .created: return .accentColor
        case .archived: return .orange
        case .restored, .subtaskCompleted: return .green
        case .subtaskRemoved: return .red
        default: return .secondary
        }
    }

    private func describe(_ prefix: String) -> String {
        guard let subject, !subject.isEmpty else { return prefix }
        return "\(prefix): \(subject)"
    }
}

enum RelativeTime {
    private static let formatter: RelativeDateTimeFormatter = {
        let format = RelativeDateTimeFormatter()
        format.unitsStyle = .abbreviated
        return format
    }()
    
    static func string(from date: Date, now: Date = Date()) -> String {
        guard now.timeIntervalSince(date) >= 60 else {
            return "just now"
        }
        
        return formatter.localizedString(for: date, relativeTo: now)
    }
}

enum AbsoluteTime {
    static func string(from date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}

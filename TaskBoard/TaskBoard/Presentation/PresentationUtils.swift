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

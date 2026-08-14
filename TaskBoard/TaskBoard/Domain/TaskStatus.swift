//
//  TaskStatus.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

enum TaskStatus: String, CaseIterable, Identifiable, Codable {
    case todo
    case inProgress
    case done
    
    var id: String { rawValue }
    
    var sortOrder: Int {
        switch self {
        case .todo: return 0
        case .inProgress: return 1
        case .done: return 2
        }
    }
}

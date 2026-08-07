//
//  BoardError.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum BoardError: LocalizedError {
    case loadFailed(reason: String)
    case persistenceFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let reason):
            return "Could not load your task board. \(reason)"
        case .persistenceFailed(let reason):
            return "Could not save your changes. \(reason)"
        }
    }
}

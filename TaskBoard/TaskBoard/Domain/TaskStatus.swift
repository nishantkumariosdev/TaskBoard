//
//  TaskStatus.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation

enum TaskStatus: String, CaseIterable, Identifiable {
    case todo
    case inProgress
    case done
    
    var id: String { rawValue }
}

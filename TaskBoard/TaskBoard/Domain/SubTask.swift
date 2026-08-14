//
//  SubTask.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 14/08/26.
//

import Foundation

struct SubTask: Identifiable, Equatable, Codable, Sendable {
    let id: String
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

extension SubTask {
    func toggled() -> SubTask {
        var copy = self
        copy.isCompleted.toggle()
        return copy
    }
}

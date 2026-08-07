//
//  TaskRepository.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
protocol TaskRepository: AnyObject {
    func observeTasks() -> AsyncStream<[BoardTask]>
    
    func load() throws
    
    func allTasks() throws -> [BoardTask]
    
    func task(id: String) throws -> BoardTask?
    
    func save(_ task: BoardTask) throws
    
    func saveAll(_ tasks: [BoardTask]) throws
    
    func delete(id: String) throws
}

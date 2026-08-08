//
//  LocalTaskStore.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
protocol LocalTaskStore: AnyObject {
    func observe() -> AsyncStream<[BoardTask]>
    
    func publishCurrent() throws
    
    func fetchAll() throws -> [BoardTask]
    
    func fetch(id: String) throws -> BoardTask?
    
    func upsert(_ tasks: [BoardTask]) throws
    
    func delete(ids: [String]) throws
}

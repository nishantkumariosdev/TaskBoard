//
//  LocalTaskStoreContainer.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import SwiftData

struct LocalTaskStoreContainer {
    let modelContainer: ModelContainer
    
    static let schema = Schema([TaskEntity.self])
    
    static func forApp() -> LocalTaskStoreContainer {
        if let container = try? makeContainer(inMemory: false) {
            return LocalTaskStoreContainer(modelContainer: container)
        }
        AppLog.store("on disk store unavailable, falling back to memory, this session won't be saved")
        
        do {
            return LocalTaskStoreContainer(modelContainer: try makeContainer(inMemory: true))
        } catch {
            fatalError("SwiftData is not usable: \(error)")
        }
    }
    
    
    private static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
}

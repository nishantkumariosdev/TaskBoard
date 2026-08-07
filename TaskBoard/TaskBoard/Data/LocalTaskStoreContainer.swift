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
    let degradationError: BoardError?
    
    static let schema = Schema([TaskEntity.self])
    
    static func forApp() -> LocalTaskStoreContainer {
        if let container = try? makeContainer(inMemory: false) {
            return LocalTaskStoreContainer(modelContainer: container, degradationError: nil)
        }
        
        do {
            return LocalTaskStoreContainer(
                modelContainer: try makeContainer(inMemory: true),
                degradationError: .persistenceFailed(reason: "Task board could not be opened on disk, so this session will not be saved")
            )
        } catch {
            fatalError("SwiftData is not usable: \(error)")
        }
    }
    
    static func inMemory() throws -> LocalTaskStoreContainer {
        return LocalTaskStoreContainer(
            modelContainer: try makeContainer(inMemory: true),
            degradationError: nil
        )
    }
    
    private static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
}

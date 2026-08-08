//
//  ConflictResolver.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum ConflictResolution: Equatable {
    case keepLocal
    case takeServer
}

enum ConflictResolver {

    static func resolve(local: BoardTask, server: BoardTask) -> ConflictResolution {
        guard !local.syncState.isPending else { return .keepLocal }
        return server.updatedAt > local.updatedAt ? .takeServer : .keepLocal
    }
}

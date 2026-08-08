//
//  ConflictResolver.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum ConflictResolution: Equatable {
    case keepLocal
    case takeRemote
}

enum ConflictResolver {

    static func resolve(local: BoardTask, remote: BoardTask) -> ConflictResolution {
        remote.updatedAt > local.updatedAt ? .takeRemote : .keepLocal
    }
}

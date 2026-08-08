//
//  SyncState.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum SyncState: String, Codable, Sendable {
    case synced
    case pendingSave
    case pendingDelete

    var isPending: Bool { self != .synced }
}

struct SyncStatus: Equatable, Sendable {
    var lastSyncedAt: Date?
    var pendingCount: Int = 0
    var isSyncing: Bool = false
    var isOnline: Bool = true

    static let localOnly = SyncStatus(lastSyncedAt: nil, isOnline: true)
}

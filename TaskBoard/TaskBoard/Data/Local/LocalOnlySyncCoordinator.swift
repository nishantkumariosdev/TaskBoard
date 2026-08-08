//
//  LocalOnlySyncCoordinator.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class LocalOnlySyncCoordinator: SyncCoordinating {

    private var observers: [UUID: AsyncStream<SyncStatus>.Continuation] = [:]

    func observeStatus() -> AsyncStream<SyncStatus> {
        AsyncStream { continuation in
            let id = UUID()
            observers[id] = continuation
            continuation.yield(.localOnly)

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.observers[id] = nil }
            }
        }
    }

    func start() {}
    func syncNow() async {}
    func requestSync() {}
}

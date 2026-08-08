//
//  LocalOnlySyncCoordinator.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
final class LocalOnlySyncCoordinator: SyncCoordinating {

    private var observers: [UUID: AsyncStream<Date?>.Continuation] = [:]

    func observeLastSynced() -> AsyncStream<Date?> {
        AsyncStream { continuation in
            let id = UUID()
            observers[id] = continuation
            continuation.yield(nil)

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.observers[id] = nil }
            }
        }
    }

    func start() {}

    func refresh() async {}

    func push(_ task: BoardTask) {}

    func pushDelete(id: String) {}
}

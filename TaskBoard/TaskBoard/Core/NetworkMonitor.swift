//
//  NetworkMonitor.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import Network

@MainActor
final class NetworkMonitor {
    private(set) var isOnline = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.nishant.TaskBoard.network")
    private var isStarted = false

    func start(onChange: @escaping @MainActor (Bool) -> Void) {
        guard !isStarted else { return }
        isStarted = true

        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            Task { @MainActor in
                guard let self, online != self.isOnline else { return }
                self.isOnline = online
                onChange(online)
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}


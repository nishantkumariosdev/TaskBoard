//
//  SyncCoordinating.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
protocol SyncCoordinating: AnyObject {
    func observeStatus() -> AsyncStream<SyncStatus>

    func start()

    func syncNow() async

    func requestSync()
}

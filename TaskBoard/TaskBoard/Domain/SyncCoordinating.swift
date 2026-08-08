//
//  SyncCoordinating.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

@MainActor
protocol SyncCoordinating: AnyObject {
    func observeLastSynced() -> AsyncStream<Date?>

    func start()

    func refresh() async

    func push(_ task: BoardTask)

    func pushDelete(id: String)
}

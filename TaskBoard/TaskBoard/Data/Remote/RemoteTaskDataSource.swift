//
//  RemoteTaskDataSource.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

protocol RemoteTaskDataSource: Sendable {
    func fetchAll() async throws -> [BoardTask]

    func upsert(_ task: BoardTask) async throws

    func delete(id: String) async throws
}

//
//  FirebaseDatabaseTaskDataSource.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

struct FirebaseDatabaseTaskDataSource: RemoteTaskDataSource {

    private let databaseURL: URL
    private let boardNode: String
    private let client: HTTPClient

    init(databaseURL: URL, boardNode: String, client: HTTPClient) {
        self.databaseURL = databaseURL
        self.boardNode = boardNode
        self.client = client
    }

    func fetchAll() async throws -> [BoardTask] {
        let data = try await client.send(HTTPRequest(url: endpoint(), method: .get))
        guard !isNull(data) else { return [] }

        do {
            let keyed = try JSONDecoder().decode([String: RemoteTaskDTO].self, from: data)
            return keyed.values.map { $0.toDomain() }
        } catch {
            throw BoardError.remoteFailed(
                reason: "The board data couldn't be read. \(error.localizedDescription)"
            )
        }
    }

    func upsert(_ task: BoardTask) async throws {
        let body: Data
        do {
            body = try JSONEncoder().encode(RemoteTaskDTO(task))
        } catch {
            throw BoardError.remoteFailed(reason: "Couldn't encode the task. \(error.localizedDescription)")
        }

        _ = try await client.send(
            HTTPRequest(url: endpoint(taskID: task.id), method: .put, body: body)
        )
    }

    func delete(id: String) async throws {
        _ = try await client.send(HTTPRequest(url: endpoint(taskID: id), method: .delete))
    }

    private func endpoint(taskID: String? = nil) -> URL {
        var url = databaseURL
            .appendingPathComponent("boards")
            .appendingPathComponent(boardNode)
            .appendingPathComponent("tasks")

        if let taskID {
            url = url.appendingPathComponent(taskID)
        }

        return url.appendingPathExtension("json")
    }

    private func isNull(_ data: Data) -> Bool {
        guard !data.isEmpty else { return true }
        let text = String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text == "null"
    }
}


//
//  HTTPClient.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

struct HTTPRequest: Sendable {
    enum Method: String, Sendable {
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }

    let url: URL
    let method: Method
    var body: Data?
}

protocol HTTPClient: Sendable {
    func send(_ request: HTTPRequest) async throws -> Data
}

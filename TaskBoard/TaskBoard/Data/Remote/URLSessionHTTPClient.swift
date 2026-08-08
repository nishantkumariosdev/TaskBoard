//
//  URLSessionHTTPClient.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let timeout: TimeInterval

    init(session: URLSession = .shared, timeout: TimeInterval = 15) {
        self.session = session
        self.timeout = timeout
    }

    func send(_ request: HTTPRequest) async throws -> Data {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = timeout

        if let body = request.body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let label = "\(request.method.rawValue) \(request.url.path)"

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let http = response as? HTTPURLResponse else {
                throw BoardError.remoteFailed(reason: "The server sent a response we couldn't read.")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw BoardError.remoteFailed(reason: Self.describe(status: http.statusCode))
            }
            
            AppLog.network("\(label): \(http.statusCode), \(data.count) bytes")
            return data
        } catch let error as BoardError {
            throw error
        } catch {
            AppLog.network("\(label): \(error.localizedDescription)")
            throw BoardError.remoteFailed(reason: error.localizedDescription)
        }
    }

    private static func describe(status: Int) -> String {
        switch status {
        case 401, 403:
            return "The database rejected the request (\(status)). Check the database rules."
        case 404:
            return "The database URL couldn't be found (404). Check DatabaseURL in FirebaseConfig.plist."
        default:
            return "The server returned \(status)."
        }
    }
}

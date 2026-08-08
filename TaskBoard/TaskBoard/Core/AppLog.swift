//
//  AppLog.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation

enum AppLog {
    static func app(_ message: @autoclosure () -> String) {
        write("app", message())
    }

    static func sync(_ message: @autoclosure () -> String) {
        write("sync", message())
    }

    static func network(_ message: @autoclosure () -> String) {
        write("network", message())
    }

    static func store(_ message: @autoclosure () -> String) {
        write("store", message())
    }

    private static func write(_ category: String, _ message: String) {
        #if DEBUG
        print("[TaskBoard] \(category): \(message)")
        #endif
    }
}

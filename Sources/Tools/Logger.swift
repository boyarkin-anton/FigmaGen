//
//  Logger.swift
//  
//
//  Created by Anton Boyarkin on 14.05.2021.
//

import Foundation
import Rainbow

final public class Logger {

    public enum Level: CaseIterable {
        case success
        case fatal
        case error
        case warning
        case info
        case debug
    }

    public static var verbose: Logger {
        return .init(acceptedLevels: Set(Level.allCases))
    }

    public static var `default`: Logger {
        return .init(acceptedLevels: [.error, .fatal, .info, .success, .warning])
    }
    
    public let acceptedLevels: Set<Level>

    public init(acceptedLevels: Set<Level>) {
        self.acceptedLevels = acceptedLevels
    }

    public func log(_ level: Level, _ msg: String) {
        guard acceptedLevels.contains(level) else { return }

        switch level {
        case .success:
            print("[✅] \(msg)".green)
        case .fatal:
            print("[❌] \(msg)".red.bold)
        case .error:
            print("[🛑] \(msg)".lightRed)
        case .warning:
            print("[⚠️] \(msg)".yellow)
        case .info:
            print(msg.white)
        case .debug:
            print("[🐛] \(msg)".white.bold)
        }
    }

}

extension Logger {

    public func success(_ msg: String) {
        self.log(.success, msg)
    }

    public func fatal(_ msg: String) {
        self.log(.fatal, msg)
    }

    public func error(_ msg: String) {
        self.log(.error, msg)
    }

    public func warning(_ msg: String) {
        self.log(.warning, msg)
    }

    public func info(_ msg: String) {
        self.log(.info, msg)
    }

    public func debug(_ msg: String) {
        self.log(.debug, msg)
    }

}

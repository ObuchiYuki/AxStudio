//
//  AxDebugSocketLogger.swift
//  AxStudio
//
//  Created by yuki on 2021/10/09.
//

import SwiftEx
import AxComponents
import Combine
import AppKit
import AxDocument
import SocketIO

final class AxDebugSocketLogger: SocketLogger {
    
    static let shared = AxDebugSocketLogger()
    
    let logPublisher = PassthroughSubject<(type: String, message: String, color: NSColor), Never>()
    
    var log: Bool = true {
        didSet {
            if log {
                logPublisher.send((type: "Socket Logger", message: "Start Logging", color: .systemBlue))
            }else{
                logPublisher.send((type: "Socket Logger", message: "Stop Logging", color: .red))
            }
        }
    }
    
    func log(_ message: @autoclosure () -> String, type: String) {
        let _message = message()
        DispatchQueue.main.async {
            if self.log { self.logPublisher.send((type, _message, .textColor)) }
        }
    }

    func error(_ message: @autoclosure () -> String, type: String) {
        let _message = message()
        DispatchQueue.main.async {
            if self.log { self.logPublisher.send((type, _message, .red)) }
        }
    }
}

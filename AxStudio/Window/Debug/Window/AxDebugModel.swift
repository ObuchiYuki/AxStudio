//
//  AxDebugModel.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import SwiftEx
import AxDocument
import AppKit
import Combine

final class AxDebugModel {
    enum ContentMode {
        case websocket
        case document
        case model
        case pasteboard
    }
    
    let document: AxDocument
    
    @ObservableProperty var contentMode: ContentMode = .websocket
    
    let logPublisher = PassthroughSubject<NSAttributedString, Never>()
    let resetLogPublisher = PassthroughSubject<Void, Never>()
    let logFont = NSFont.monospacedSystemFont(ofSize: 10, weight: .bold)
    
    func sendLog(type: String, message: String, color: NSColor) {
        DispatchQueue.main.async {[self] in
            let log = "[\(type)]".padding(toLength: 26, withPad: " ", startingAt: 0) + message + "\n"
            
            let attrString = NSAttributedString(
                string: log,
                attributes: [
                    NSAttributedString.Key.foregroundColor : color,
                    NSAttributedString.Key.font : logFont,
                ]
            )
            logPublisher.send(attrString)
        }
    }
    
    init(document: AxDocument) {
        self.document = document
    }
}

extension NSViewController {
    var debugModel: AxDebugModel { chainObject as! AxDebugModel }
}

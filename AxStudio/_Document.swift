//
//  _Document.swift
//  AxStudio
//
//  Created by yuki on 2022/01/18.
//

import AppKit

class Document: NSDocument {
    override init() { super.init() }

    override func makeWindowControllers() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return Data()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        
    }
}


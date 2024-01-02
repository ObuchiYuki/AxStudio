//
//  AxLocalDocument+Window.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxDocument
import AxModelCore
import AppKit
import LayoutEngine

extension AxLocalDocument {
    static func activate() {
        self.makeWindowControllersBlock = AxLocalDocument.makeWindowControllers
        self.showWindowsBlock = AxLocalDocument.showWindows
    }
    
    private static func makeWindowControllers(_ document: AxLocalDocument) {
        let windowController = AxAppWindowController.instantiate()
        document.addWindowController(windowController)
        let session = AxModelSession.publish(client: document, errorHandler: AxToastErrorHandler(), undoManager: document.undoManager)
        AxDocument.connect(session: session)
            .peek{ document in
                windowController.chainObject = document
                document.clientType = .local(AxDocument.LocalClientInfo())
            }
            .catchOnToast()
    }
    
    private static func showWindows(_ document: AxLocalDocument) {
        for windowController in document.windowControllers {
            windowController.showWindow(document)
        }
    }
}

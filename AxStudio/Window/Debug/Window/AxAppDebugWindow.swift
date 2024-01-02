//
//  AxAppDebugWindow.swift
//  AxStudio
//
//  Created by yuki on 2021/10/07.
//

import AppKit
import AxComponents
import AxModelCore
import AxDocument
import SwiftEx
import AppKit

final class AxDebugWindowController: NSWindowController {
    static func instantiate(document: AxDocument) -> AxDebugWindowController {
        let model = AxDebugModel(document: document)
        let window = NSWindow(contentViewController: AxDebugContentViewController())
        window.setFrameAutosaveName("debugWindow")
        window.styleMask.insert([.fullSizeContentView])
        window.title = "Debug Document"
        window.minSize = [540, 540]
        window.setContentSize([540, 540])

        let windowController = AxDebugWindowController(window: window)
        windowController.chainObject = model
        return windowController
    }
    
    func showWindowWithContentMode(_ contentMode: AxDebugModel.ContentMode) {
        self.contentViewController?.debugModel.contentMode = contentMode
        self.showWindow(nil)
    }
}

extension NSWindow.StyleMask: ExtendOptionSet {
    public static var labels: [(NSWindow.StyleMask, String)] = [
        (.borderless, "borderless"),
        (.titled, "titled"),
        (.closable, "closable"),
        (.miniaturizable, "miniaturizable"),
        (.resizable, "resizable"),
        (.texturedBackground, "texturedBackground"),
        (.unifiedTitleAndToolbar, "unifiedTitleAndToolbar"),
        (.fullScreen, "fullScreen"),
        (.fullSizeContentView, "fullSizeContentView"),
        (.utilityWindow, "utilityWindow"),
        (.docModalWindow, "docModalWindow"),
        (.nonactivatingPanel, "nonactivatingPanel"),
        (.hudWindow, "hudWindow"),
    ]
}

















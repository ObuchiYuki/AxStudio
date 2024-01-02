//
//  AxDebugWebSocketViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents

final class AxDebugWSViewController: NSSplitViewController {
    let stackViewController = AxDebugWSStackViewController()
    let loggerViewController = AxDebugWSLoggerViewController()
    
    override func chainObjectDidLoad() {
        self.stackViewController.chainObject = self.chainObject
        self.loggerViewController.chainObject = self.chainObject
    }

    override func viewDidLoad() {
        self.splitView.isVertical = false
        self.splitView.autosaveName = "websocket_debug"
        
        let stackItem = NSSplitViewItem(viewController: stackViewController)
        stackItem.minimumThickness = 160
        self.addSplitViewItem(stackItem)
        
        let loggerItem = NSSplitViewItem(viewController: loggerViewController)
        loggerItem.minimumThickness = 160
        self.addSplitViewItem(loggerItem)
    }
}


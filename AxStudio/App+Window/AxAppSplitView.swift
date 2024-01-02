//
//  MainSplitViewController.swift
//  AxStudio
//
//  Created by yuki on 2020/04/07.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxComponents
import AxDocument
import SwiftEx
import AppKit

final class AxSplitViewController: NSSplitViewController {
    
    private let navigatorViewController = AxNavigatorViewController()
    private let editorViewController = AxFlipEditorViewController()
    private let indicatorViewController = AxIndicatorViewController()
    
    private lazy var navigatorItem = NSSplitViewItem(sidebarWithViewController: navigatorViewController)
    private lazy var editorItem = NSSplitViewItem(viewController: editorViewController)
    private lazy var indicatorItem = NSSplitViewItem(sidebarWithViewController: indicatorViewController)
    
    override func chainObjectDidLoad() {
        self.splitView.autosaveName = "app.split.\(document.rootNode.id)"
        self.navigatorItem.isCollapsed = false
        
        self.navigatorViewController.chainObject = chainObject
        self.editorViewController.chainObject = chainObject
        self.indicatorViewController.chainObject = chainObject
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigatorItem.minimumThickness = 250
        navigatorItem.maximumThickness = 480
        navigatorItem.canCollapse = false
        navigatorItem.holdingPriority = .init(250)
        self.addSplitViewItem(navigatorItem)
        
        editorItem.canCollapse = false
        editorItem.holdingPriority = .init(249)
        self.addSplitViewItem(editorItem)

        indicatorItem.minimumThickness = 260
        indicatorItem.maximumThickness = 480
        indicatorItem.canCollapse = false
        indicatorItem.holdingPriority = .init(250)
        self.addSplitViewItem(indicatorItem)
        
        self.splitView.setPosition(250, ofDividerAt: 0)
    }
}

final class AxAppSplitView: NSSplitView {
    override var isFlipped: Bool { true }
    override var dividerThickness: CGFloat { 0 }
    override func draw(_ dirtyRect: NSRect) {
        R.Color.editorBackgroundColor.setFill()
        dirtyRect.fill()
    }
}

//
//  +AxEditorView.swift
//  AxStudio
//
//  Created by yuki on 2020/07/20.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxDocument
import SwiftEx
import AxCommand
import LapixUI
import EmeralyUI

final class AxEditorSplitViewController: NSSplitViewController {
    private let canvasVC = AxCanvasViewController()
    private let workbenchVC = AxWorkbenchEditorViewController()
    private let workbenchHeaderVC = AxWorkbenchHeaderViewController()
    
    override func loadView() {
        self.splitView = AxEditorSplitView()
        super.loadView()
    }
    
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        self.splitView.autosaveName = "editor.\(document.rootNode.id)"
        self.workbenchHeaderVC.chainObject = chainObject
        self.canvasVC.chainObject = chainObject
        self.workbenchVC.chainObject = chainObject
    }
    
    override func viewDidLoad() {
        let canvasItem = NSSplitViewItem(viewController: canvasVC)
        canvasItem.minimumThickness = 180
        canvasItem.holdingPriority = .init(rawValue: 250)
        self.addSplitViewItem(canvasItem)
        
        let bluePrintItem = NSSplitViewItem(viewController: workbenchVC)
        bluePrintItem.minimumThickness = 120
        bluePrintItem.canCollapse = true
        bluePrintItem.holdingPriority = .init(rawValue: 251)
        self.addSplitViewItem(bluePrintItem)
    }
    
    override func viewWillAppear() {
        guard let divider = splitView.subviews.first(where: { type(of: $0).description().contains("Divider") }) else {
            return
        }

        self.parent?.addChild(workbenchHeaderVC)
        self.view.superview?.addSubview(workbenchHeaderVC.view)
        divider.publisher(for: \.frame)
            .sink{[unowned self] in
                workbenchHeaderVC.view.frame = $0.insetBy(dx: 0, dy: 2)
            }
            .store(in: &objectBag)
    }
}

final private class AxEditorSplitView: NSLoadSplitView {
    override var dividerThickness: CGFloat { 24 }
    
    override func onAwake() {
        self.isVertical = false
        self.dividerStyle = .thin
    }
}

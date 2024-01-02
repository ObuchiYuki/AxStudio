//
//  AxAssetNavigatorViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import AppKit
import AxDocument
import DesignKit
import Combine
import STDComponents
import SwiftEx
import AxComponents

final class AxNavigatorViewController: NSSplitViewController {
    private let layersController = AxLayersViewController()
    private let assetController = AxAssetViewController()
        
    override func chainObjectDidLoad() {
        self.splitView.setPosition(500, ofDividerAt: 0)
        self.splitView.autosaveName = "navi.split.\(document.rootNode.id)"
        
        self.layersController.chainObject = self.chainObject
        self.assetController.chainObject = self.chainObject
    }
    
    override func viewDidLoad() {
        self.splitView.isVertical = false
        self.splitView.dividerStyle = .thin
        
        let layersItem = NSSplitViewItem(viewController: layersController)
        layersItem.minimumThickness = 300
        layersItem.holdingPriority = .init(250)
        self.addSplitViewItem(layersItem)
                
        let assetItem = NSSplitViewItem(viewController: assetController)
        assetItem.minimumThickness = 250
        assetItem.holdingPriority = .init(251)
        self.addSplitViewItem(assetItem)
    }
}


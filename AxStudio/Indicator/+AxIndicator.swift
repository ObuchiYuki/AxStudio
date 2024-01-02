//
//  AxIndicatorViewController.swift
//  AxStudio
//
//  Created by yuki on 2020/05/13.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AxDocument
import AxComponents
import BluePrintKit

final class AxIndicatorViewController: NSViewController {
    private let designIndicator = AxDesignIndicatorViewController()
    private let appIndicator = AxAppIndicatorViewController()
    private let nodeIndicator = AxNodeIndicatorViewController()
    private let noneIndicator = ACAreaViewController.text("Nothing Selected")
    private let multipleIndicator = ACAreaViewController.text("Multiple Selection")
    
    final private class View: NSPlaceholderView<NSView> {
        override var isFlipped: Bool { true }
    }

    private let indicatorView = View()

    override func loadView() { self.view = indicatorView }
    
    override func mouseDown(with event: NSEvent) {
        ACPicker.close()
    }

    override func chainObjectDidLoad() {
        self.designIndicator.chainObject = self.chainObject
        self.appIndicator.chainObject = self.chainObject
        self.nodeIndicator.chainObject = self.chainObject
        self.noneIndicator.chainObject = self.chainObject
        self.multipleIndicator.chainObject = self.chainObject
        
        document.sidebarTypePublisher
            .sink{[unowned self] in
                switch $0 {
                case .design:
                    if document.selectedLayers.isEmpty {
                        self.contentVC = appIndicator
                    } else {
                        self.contentVC = designIndicator
                    }
                case .bluePrint:
                    guard let container = document.currentNodeContainer else { return }
                    self.setState(container, for: .bluePrint)
                    
                    if container.selectedNodes.isEmpty {
                        self.contentVC = noneIndicator
                    } else if container.selectedNodes.count == 1 {
                        self.contentVC = nodeIndicator
                    } else {
                        self.contentVC = multipleIndicator
                    }
                }
            }
            .store(in: &objectBag)
        
        document.currentNodeContainerp.combineLatest(document.currentNodeContainerp.compactMap{ $0?.$selectedNodes }.switchToLatest())
            .sink{[unowned self] container, nodes in
                if nodes.count == 1 {
                    self.contentVC = nodeIndicator
                    self.setState(container, for: .bluePrint)
                }
            }
            .store(in: &objectBag)
        
        document.$selectedLayers
            .sink {[unowned self] layers in
                if layers.isEmpty {
                    self.contentVC = appIndicator
                } else {
                    self.contentVC = designIndicator
                }
            }
            .store(in: &objectBag)
    }

    private var contentVC: NSViewController? {
        didSet {
            guard oldValue !== contentVC else { return }
            oldValue?.removeFromParent()
            if let contentVC = contentVC {
                self.addChild(contentVC)
                self.indicatorView.contentView = contentVC.view
            }
        }
    }
}

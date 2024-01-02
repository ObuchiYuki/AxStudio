//
//  AxDebugBodyViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents

final class AxDebugBodyViewController: NSViewController {
    private let websocketView = AxDebugWSViewController()
    private let documentView = AxDebugDCViewController()
    private let modelView = AxDebugModelViewController()
    private let pasteboardView = AxDebugPasteboardViewController()
    
    private let bodyView = AxDebugBodyContainerView()
    
    private var contentViewController: NSViewController?
    
    override func loadView() { self.view = bodyView }
    
    override func chainObjectDidLoad() {
        self.debugModel.$contentMode
            .sink{[unowned self] in self.updateContentView($0) }.store(in: &objectBag)
    }
    
    private func updateContentView(_ contentMode: AxDebugModel.ContentMode) {
        switch contentMode {
        case .websocket: self.setContentViewController(websocketView)
        case .document: self.setContentViewController(documentView)
        case .model: self.setContentViewController(modelView)
        case .pasteboard: self.setContentViewController(pasteboardView)
        }
    }
    
    private func setContentViewController(_ viewController: NSViewController) {
        contentViewController?.removeFromParent()
        self.contentViewController = viewController
        self.addChild(viewController)
        self.bodyView.contentView = viewController.view
    }
}

final private class AxDebugBodyContainerView: NSView {
    var contentView: NSView? {
        didSet {
            oldValue?.removeFromSuperview()
        
            if let contentView = contentView {
                self.addSubview(contentView)
                contentView.snp.makeConstraints{ make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}


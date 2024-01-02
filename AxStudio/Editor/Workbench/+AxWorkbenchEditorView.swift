//
//  +AxWorkbenchEditorView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/22.
//

import AppKit
import SwiftEx
import AppKit

final class AxWorkbenchEditorViewController: NSViewController {
    private let bluePrintController = AxBluePrintEditorViewController()
    private let tableController = AxTableEditorViewController()
    
    private let editorView = AxWorkbenchEditorView()
    
    private var contentVC: NSViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let contentVC = contentVC {
                self.addChild(contentVC)
                self.editorView.contentView = contentVC.view
            }
        }
    }
    
    override func loadView() { self.view = editorView }
    
    override func chainObjectDidLoad() {
        document.$selectedTable
            .sink{[unowned self] table in
                if table != nil {
                    self.contentVC = tableController
                } else {
                    self.contentVC = bluePrintController
                }
            }
            .store(in: &objectBag)
    }
}

final private class AxWorkbenchEditorView: NSView {
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

//
//  +AxFlipEditorView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/23.
//

import SwiftEx
import AppKit

final class AxFlipEditorViewController: NSViewController {
    let editorSplitViewController = AxEditorSplitViewController()
    
    override func loadView() {
        self.view = AxFlipEditorView()
    }
    override func viewDidLoad() {
        self.addChild(editorSplitViewController)
        self.view.addSubview(editorSplitViewController.view)
        self.editorSplitViewController.view.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

final private class AxFlipEditorView: NSView {
    override var isFlipped: Bool { true }
}


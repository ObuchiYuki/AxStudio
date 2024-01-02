//
//  +AxCanvasView.swift
//  AxStudio
//
//  Created by yuki on 2020/11/21.
//  Copyright © 2020 yuki. All rights reserved.
//

import LapixUI
import DesignKit
import SwiftEx
import AxDocument
import AppKit
import AxCommand
import AxComponents
import AxModelCore

class AxCanvasViewController: LPCanvasViewController {
    override func rightMouseDown(with event: NSEvent) {
        let menu = AxLayerMenuGenerator(document: document, view: self.view).make(for: .canvas)
        menu.popUp(positioning: nil, at: view.convert(event.locationInWindow, from: nil), in: view)
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if event.modifierFlags.contains(.function) {
//            #warning("未実装")
            AxLayerLayoutInfo.showInfo(document, view: self.view)
        }
    }
    
    
    override func viewDidLayout() {
        document?.execute(AxCanvasViewSizeCommand(size: view.frame.size))
    }
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        self.viewDidLayout()
    }
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(self)
    }
    
    @IBAction func copy(_ sender: Any) {
        document?.execute(AxCopyLayerCommand())
    }
    @IBAction func paste(_ sender: Any) {
        document?.execute(AxCanvasPasteCommand())
    }
    @IBAction func cut(_ sender: Any) {
        document?.execute(AxCutLayerCommand())
    }
    @IBAction func duplicate(_ sender: Any) {
        document?.execute(AxDuplicateLayerCommand())
    }
    @IBAction func delete(_ sender: Any) {
        document?.execute(AxRemoveLayersCommand())
    }
}

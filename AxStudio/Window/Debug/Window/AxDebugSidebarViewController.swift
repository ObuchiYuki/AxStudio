//
//  AxDebugSidebarViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents

final class AxDebugSidebarViewController: ACSidebarViewController {
    let documentHeader = ACSidebarTitleItem(title: "Document", style: .header)
    let webSocketItem = ACSidebarIconTitleItem(icon: R.Image.debugWebsocket, title: "WebSocket")
    let documentItem = ACSidebarIconTitleItem(icon: R.Image.debugDocument, title: "Document")
    let modelItem = ACSidebarIconTitleItem(icon: R.Image.debugModel, title: "Model")
    let pasteboardItem = ACSidebarIconTitleItem(icon: R.Image.debugModel, title: "Pasteboard")
    
    override func chainObjectDidLoad() {
        self.debugModel.$contentMode
            .sink{[unowned self] in
                switch $0 {
                case .websocket: self.selectItem(webSocketItem)
                case .document: self.selectItem(documentItem)
                case .model: self.selectItem(modelItem)
                case .pasteboard: self.selectItem(pasteboardItem)
                }
            }
            .store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.scrollView.drawsBackground = false
        self.addItem(documentHeader)
        self.addItem(webSocketItem) { self.debugModel.contentMode = .websocket }
        self.addItem(documentItem) { self.debugModel.contentMode = .document }
        self.addItem(modelItem) { self.debugModel.contentMode = .model }
        self.addItem(pasteboardItem) { self.debugModel.contentMode = .pasteboard }
    }
}

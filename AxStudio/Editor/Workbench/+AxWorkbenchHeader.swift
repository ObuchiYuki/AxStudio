//
//  +AxBleuPrintEditorHeader.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import AppKit
import SwiftEx
import DesignKit
import BluePrintKit
import AxComponents
import Combine

final class AxWorkbenchHeaderViewController: NSViewController {
    let bluePrintHeaderController = AxBluePrintHeaderViewController()
    let tableHeaderController = AxTableHeaderViewController()
    
    private let headerView = AxWorkbenchHeaderView()
    
    private var contentVC: NSViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let contentVC = contentVC {
                self.addChild(contentVC)
                self.headerView.contentView = contentVC.view
            }
        }
    }
    
    override func loadView() {
        self.view = headerView
    }
    
    override func chainObjectDidLoad() {
        document.$selectedTable
            .sink{[unowned self] table in
                if table != nil {
                    self.contentVC = tableHeaderController
                } else {
                    self.contentVC = bluePrintHeaderController
                }
            }
            .store(in: &objectBag)
    }
}


final private class AxWorkbenchHeaderView: NSLoadView {
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
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    
    private let separator1 = NSColorView()
    private let separator2 = NSColorView()
    
    override func onAwake() {
        self.wantsLayer = true
        
        self.addSubview(separator1)
        self.separator1.backgroundColor = NSColor.textColor.withAlphaComponent(0.1)
        self.separator1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.addSubview(separator2)
        self.separator2.backgroundColor = NSColor.textColor.withAlphaComponent(0.1)
        self.separator2.snp.makeConstraints{ make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

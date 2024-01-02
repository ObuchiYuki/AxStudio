//
//  +AxTableHeaderView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/22.
//

import SwiftEx
import AppKit
import AxComponents

final class AxTableHeaderViewController: NSViewController {
    private let headerView = AxTableHeaderView()
    
    override func loadView() {
        self.view = headerView
    }
    
    override func chainObjectDidLoad() {
        self.headerView.closeButton.actionPublisher
            .sink{[unowned self] in document.selectedTable = nil }.store(in: &objectBag)
    }
}

final private class AxTableHeaderView: NSLoadView {
    let closeButton = AxClosedTableButton()
    
    override func onAwake() {
        self.addSubview(closeButton)
        self.closeButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.height.equalTo(18)
        }
    }
}

final private class AxClosedTableButton: NSLoadButton {
    
    private let backgroundLayer = CALayer.animationDisabled()
    private let iconView = NSImageView(image: R.Image.closeTable)
    private let titleLabel = NSTextField(labelWithString: "Close Table")
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func updateLayer() {
        if isHighlighted {
            self.backgroundLayer.backgroundColor = NSColor.textColor.withAlphaComponent(0.4).cgColor
        } else {
            self.backgroundLayer.backgroundColor = NSColor.textColor.withAlphaComponent(0.3).cgColor
        }
    }
    
    override func onAwake() {
        self.isBordered = false
        self.title = ""
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        self.backgroundLayer.cornerRadius = AxComponents.R.Size.controlCorner
        
        self.addSubview(iconView)
        self.iconView.snp.makeConstraints{ make in
            make.size.equalTo(13)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(4)
        }
        
        self.addSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: AxComponents.R.FontSize.control)
        self.titleLabel.textColor = .white
        self.titleLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
        }
    }
}

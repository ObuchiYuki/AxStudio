//
//  AxHomeDocumentItemView.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import Combine

final class AxHomeDocumentItemView: NSRectangleView {
    var itemModel: AxHomeCollectionItemModel? { didSet { self.onItemModelLoaded() } }
    
    var isSelected: Bool = false { didSet { updateSelection() } }
         
    private let thumnailImageView = AxHomeDocumentPreviewView()
    private let documentTypeIconView = NSImageView()
    private let titleLabel = NSTextField()
    private let infoLabel = NSTextField()
    private let menuButton = AxHomeDocumentMenuButton()
    
    private let titleStackView = NSStackView()
    private let footerView = NSRectangleView()
    
    private func updateSelection() {
        if self.isSelected {
            self.layer?.borderWidth = 2
            self.layer?.borderColor = NSColor.controlAccentColor.cgColor
        }else{
            self.layer?.borderWidth = 1
            self.layer?.borderColor = NSColor.gray.withAlphaComponent(0.2).cgColor
        }
    }
    
    private func onItemModelLoaded() {
        guard let itemModel = self.itemModel else { return }
        
        itemModel.document.$title
            .sink{[unowned self] in self.titleLabel.stringValue = $0 }.store(in: &objectBag)
        
        self.infoLabel.stringValue = itemModel.document.infoText
        self.documentTypeIconView.image = itemModel.document.documentTypeIcon()
        
        if let thumbnail = itemModel.document.thumbnail {
            thumbnail.sink{ if let image = $0 { self.thumnailImageView.image = image } }
        } else {
            self.thumnailImageView.image = itemModel.document.documentDefaultThumbnail()
        }
            
        self.menuButton.mouseDownPublisher
            .sink{[unowned self] in self.showMenu() }.store(in: &objectBag)
        
        self.titleLabel.endEditingStringPublisher
            .sink{ itemModel.renameDocument(to: $0) }.store(in: &objectBag)
        
        self.titleLabel.isEnabled = itemModel.canRename
        self.titleLabel.isEditable = itemModel.canRename
    }
    
    private func showMenu() {
        guard let itemModel = self.itemModel else { return }
        
        let menu = NSMenu()
        
        itemModel.document.provideContextMenu(to: menu, self.renameDocument)
        
        menu.popUp(positioning: menu.items.first, at: .zero, in: menuButton)
    }
    
    private func deleteDocument(itemModel: AxHomeCollectionItemModel) {
        let alert = NSAlert()
        alert.messageText = "Documentを削除しても良いですか?"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res == .alertFirstButtonReturn {
            itemModel.deleteDocument()
        }
    }
    
    private func renameDocument() {        
        self.window?.makeFirstResponder(self.titleLabel)
    }
    
    override func onAwake() {
        
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.fillColor = R.Color.editorBackgroundColor
        self.updateSelection()
        
        self.titleStackView.orientation = .vertical
        self.titleStackView.alignment = .left
        self.titleStackView.spacing = 4
        self.titleStackView.addArrangedSubview(titleLabel)
        self.titleStackView.addArrangedSubview(infoLabel)
        
        self.titleLabel.isBezeled = false
        self.titleLabel.isBordered = false
        self.titleLabel.drawsBackground = false
        self.titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        self.titleLabel.lineBreakMode = .byTruncatingTail
        
        self.infoLabel.isBezeled = false
        self.infoLabel.isBordered = false
        self.infoLabel.isEditable = false
        self.infoLabel.isSelectable = false
        self.infoLabel.drawsBackground = false
        self.infoLabel.font = .systemFont(ofSize: 10, weight: .regular)
        self.infoLabel.lineBreakMode = .byTruncatingTail
        self.infoLabel.textColor = .secondaryLabelColor
        
        self.footerView.fillColor = .textBackgroundColor
        self.footerView.addSubview(documentTypeIconView)
        self.footerView.addSubview(titleStackView)
        self.footerView.addSubview(menuButton)
                
        self.addSubview(thumnailImageView)
        self.addSubview(footerView)
        
        self.documentTypeIconView.snp.makeConstraints{ make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }
        self.titleStackView.snp.makeConstraints{ make in
            make.left.equalTo(self.documentTypeIconView.snp.right).offset(8)
            make.right.equalTo(self.menuButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        self.menuButton.snp.makeConstraints{ make in
            make.right.equalTo(-8)
            make.centerY.equalToSuperview()
        }
        
        self.footerView.snp.makeConstraints{ make in
            make.bottom.right.left.equalToSuperview()
            make.height.equalTo(50)
        }
        self.thumnailImageView.snp.makeConstraints{ make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(self.footerView.snp.top)
        }
        self.documentTypeIconView.snp.makeConstraints{ make in
            make.size.equalTo([24, 30] as CGSize)
        }
    }
}

final private class AxHomeDocumentMenuButton: NSLoadImageView {
    let mouseDownPublisher = PassthroughSubject<Void, Never>()
    
    override func mouseDown(with event: NSEvent) {
        mouseDownPublisher.send()
    }
    
    override func onAwake() {
        self.image = R.Home.Body.menuButton
        self.snp.makeConstraints{ make in
            make.size.equalTo([25, 25] as CGSize)
        }
    }
}

final private class AxHomeDocumentPreviewView: NSLoadView {
    var image: NSImage? {
        didSet { setNeedsDisplay(.zero) }
    }
    
    private let imageLayer = CALayer.animationDisabled()
    
    override func updateLayer() {
        imageLayer.contents = image?.cgImage
    }
    override func layout() {
        imageLayer.frame = bounds
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.imageLayer.contentsGravity = .resizeAspectFill

        self.layer?.addSublayer(imageLayer)
    }
}



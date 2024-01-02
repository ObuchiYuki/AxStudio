//
//  AxHomeSidebarAccountView.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import AxComponents
import Combine
import AxDocument

final class AxHomeSidebarAccountView: ACButton {
    
    var viewModel: AxHomeAccountViewModel? { didSet { viewModelDidLoad() } }
    
    private let effectView = NSVisualEffectView()
    private let imageView = NSImageView()
    private let stackView = NSStackView()
    private let nameLabel = NSTextField(labelWithString: "")
    private let emailLabel = NSTextField(labelWithString: "")
    
    override func buttonPerformAction() {
        guard let window = self.window, let viewModel = self.viewModel, viewModel.canLogin else { return }
        
        let provider = ACSigninFormProvider(model: viewModel.signinFormModel)
        let panel = ACFormPanel(initialProvider: provider)
        panel.showSheet(on: window)
    }
    
    override func updateLayer() {
        if buttonIsHighlighted {
            self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.1).cgColor
        }else{
            self.layer?.backgroundColor = .clear
        }
    }
    
    private func viewModelDidLoad() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.$icon
            .sink{[unowned self] in
                self.imageView.setResizedImage($0)
            }
            .store(in: &objectBag)
        viewModel.$title
            .sink{[unowned self] in self.nameLabel.stringValue = $0 }
            .store(in: &objectBag)
        viewModel.$email
            .sink{[unowned self] in
                self.emailLabel.isHidden = $0 == nil
                self.emailLabel.stringValue = $0 ?? ""
            }
            .store(in: &objectBag)
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let viewModel = self.viewModel, viewModel.canLogout else {
            return super.mouseDown(with: event)
        }
        
        let menu = NSMenu()
        menu.addItem("Log out", action: { viewModel.logoutPublisher.send() })
        menu.addItem("Account", action: { self.showAccountPanel() })
        menu.popUp(positioning: nil, at: self.convert(event.locationInWindow, from: nil), in: self)
    }
    
    private func showAccountPanel() {
        guard let viewModel = self.viewModel, let window = self.window, let accountFormModel = viewModel.accountFormModel else { return }
        let provider = AxAccountFormProvider(model: accountFormModel)
        let panel = ACFormPanel(initialProvider: provider)
        panel.showSheet(on: window)
    }
    
    override func onAwake() {
        super.onAwake()
        
        self.addSubview(effectView)
        self.effectView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.imageView.image = R.Home.Sidebar.accountNoIcon
        self.imageView.wantsLayer = true
        self.imageView.layer?.cornerRadius = 18
        self.imageView.imageScaling = .scaleProportionallyUpOrDown
        self.addSubview(imageView)
        
        self.imageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.size.equalTo([36, 36] as CGSize)
            make.centerY.equalToSuperview()
        }
        
        self.stackView.orientation = .vertical
        self.stackView.alignment = .left
        self.stackView.spacing = 4
        self.addSubview(stackView)
                
        self.stackView.snp.makeConstraints{ make in
            make.left.equalTo(self.imageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(nameLabel)
        self.stackView.addArrangedSubview(emailLabel)
        
        self.nameLabel.stringValue = "Sign In"
        self.nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        
        self.emailLabel.font = .systemFont(ofSize: AxComponents.R.FontSize.control)
        self.emailLabel.textColor = .secondaryLabelColor
        self.emailLabel.stringValue = "sample@example.com"
    }
}

extension NSButton {
    public func setResizedImage(_ image: NSImage?) {
        self.image = image?.resize(to: self.frame.size)
    }
}

extension NSImageView {
    public func setResizedImage(_ image: NSImage?) {
        self.image = image?.resize(to: self.frame.size)
    }
}

extension NSImage {
    public func resize(to targetSize: CGSize) -> NSImage {
        let result = NSImage(size: targetSize)
        if targetSize == .zero { return result }
        result.lockFocus()
        defer { result.unlockFocus() }
        
        self.draw(in: NSRect(size: targetSize), from: NSRect(size: self.size), operation: .copy, fraction: 1.0)
        
        return result
    }
}

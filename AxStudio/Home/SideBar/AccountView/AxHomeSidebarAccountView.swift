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

final class AxModelSidebarAccountViewController: NSViewController {
    
    private let cell = AxHomeSidebarAccountView()
    
    override func loadView() {
        self.view = cell
    }
    
    override func chainObjectDidLoad() {
        guard let viewModel = self.chainObject as? AxHomeViewModel else { return NSSound.beep() }
        let accountViewModel = viewModel.accountViewModel
        
        accountViewModel.$icon
            .sink{[unowned self] in self.cell.imageView.setResizedImage($0) }
            .store(in: &objectBag)
        accountViewModel.$title
            .sink{[unowned self] in self.cell.nameLabel.stringValue = $0 ?? "" }
            .store(in: &objectBag)
        accountViewModel.$email
            .sink{[unowned self] in
                self.cell.emailLabel.isHidden = $0 == nil
                self.cell.emailLabel.stringValue = $0 ?? ""
            }
            .store(in: &objectBag)
        
        self.cell.logoutPublisher
            .sink{[unowned accountViewModel] in accountViewModel.logoutPublisher.send() }.store(in: &objectBag)
        self.cell._actionPublisher
            .sink{[unowned self] in self.showLoginView() }.store(in: &objectBag)
        self.cell.accountPublisher
            .sink{[unowned self] in self.showAccountPanel() }.store(in: &objectBag)
    }
    
    private func showLoginView() {
        guard let viewModel = self.chainObject as? AxHomeViewModel,
              let window = self.cell.window
        else { return NSSound.beep() }
        let accountViewModel = viewModel.accountViewModel
        guard accountViewModel.canLogin else { return }
        
        let provider = AxSigninFormProvider(model: accountViewModel.signinFormModel)
        let panel = ACFormPanel(initialProvider: provider)
        panel.showSheet(on: window)
    }
    
    private func showAccountPanel() {
        guard let viewModel = self.chainObject as? AxHomeViewModel,
              let accountFormModel = viewModel.accountViewModel.accountFormModel,
              let window = self.cell.window
        else { return NSSound.beep() }
        
        let provider = AxAccountFormProvider(model: accountFormModel)
        let panel = ACFormPanel(initialProvider: provider)
        panel.showSheet(on: window)
    }
    
}

final private class AxHomeSidebarAccountView: ACButton {
    var canLogout = false
    
    let _actionPublisher = PassthroughSubject<Void, Never>()
    
    let logoutPublisher = PassthroughSubject<Void, Never>()
    
    let accountPublisher = PassthroughSubject<Void, Never>()
    
    let effectView = NSVisualEffectView()
    let imageView = NSImageView()
    let stackView = NSStackView()
    let nameLabel = NSTextField(labelWithString: "")
    let emailLabel = NSTextField(labelWithString: "")
    
    override func buttonPerformAction() {
        self._actionPublisher.send()
    }
    
    override func updateLayer() {
        if buttonIsHighlighted {
            self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.1).cgColor
        }else{
            self.layer?.backgroundColor = .clear
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let menu = NSMenu()
        if self.canLogout {
            menu.addItem("Log out", action: { self.logoutPublisher.send() })
        }
        menu.addItem("Account", action: { self.accountPublisher.send() })
        menu.popUp(positioning: nil, at: self.convert(event.locationInWindow, from: nil), in: self)
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

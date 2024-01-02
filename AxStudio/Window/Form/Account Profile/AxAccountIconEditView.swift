//
//  AxAccountIconEditView.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import SwiftEx
import AppKit
import Combine

final class AxAccountIconEditView: NSLoadView {
    
    var imagePublisher: AnyPublisher<NSImage, Never>{ self.imageSubject.eraseToAnyPublisher() }
    var image: NSImage? { get { iconButton.image } set { iconButton.setResizedImage(newValue) } }
    
    private let iconButton = AxAccountEditButton()
    private let imageSubject = PassthroughSubject<NSImage, Never>()
    
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if NSImage.canInit(with: sender.draggingPasteboard) { return .copy }
        return .none
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        NSImage.canInit(with: sender.draggingPasteboard)
    }

    public override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        guard let pasteboard = sender?.draggingPasteboard, let image = NSImage(pasteboard: pasteboard) else { return }
        self.sendImage(image)
    }

    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(70)
        }
        
        self.addSubview(iconButton)
        self.iconButton.snp.makeConstraints{ make in
            make.top.bottom.left.equalToSuperview()
        }
        
        self.iconButton.actionPublisher
            .sink{[unowned self] in showOpenPanel() }.store(in: &objectBag)
        
        self.registerForDraggedTypes([.URL, .fileURL, .fileContents, .pdf, .png, .tiff])
    }
    
    private func showOpenPanel() {
        guard let window = self.window else { assertionFailure("No window"); return NSSound.beep() }
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["gif", "jpg", "png", "jpeg", "tiff", "pdf"]
        openPanel.beginSheetModal(for: window) { res in
            if res == .OK, let url = openPanel.url, let image = NSImage(contentsOf: url) {
                self.sendImage(image)
            }
        }
    }
    
    private func sendImage(_ image: NSImage) {
        let trimImage = image.trimIcon(to: [320, 320])
        self.imageSubject.send(trimImage)
    }
}

final class AxAccountEditButton: NSLoadButton {
    
    override func draw(_ dirtyRect: NSRect) {
        let cornerRadius = bounds.size.minElement / 2
        let boundsPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
        boundsPath.setClip()
        self.image?.draw(in: bounds)
        
        if isHighlighted {
            NSColor.black.withAlphaComponent(0.7).setFill()
        }else{
            NSColor.black.withAlphaComponent(0.5).setFill()
        }
        boundsPath.fill()
        
        ("編集" as NSString).draw(
            center: bounds,
            attributes: [
                .foregroundColor : NSColor.white,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
    }
    
    override func drawFocusRingMask() {
        let cornerRadius = bounds.size.minElement / 2
        let boundsPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
        boundsPath.fill()
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.size.equalTo([70, 70] as CGSize)
        }
        
        self.bezelStyle = .inline
        self.isBordered = false
        self.image = R.Home.Sidebar.defaultProfile
    }
}

extension NSImage {
    public func trimIcon(to size: CGSize) -> NSImage {
        let result = NSImage(size: size)
        result.lockFocus()

        let destRect = CGRect(size: size)
        let minElement = self.size.minElement
        let fromRect = CGRect(center: self.size.convertToPoint()/2, size: [minElement, minElement])
        self.draw(in: destRect, from: fromRect, operation: .copy, fraction: 1.0)

        result.unlockFocus()
        return result
    }
}

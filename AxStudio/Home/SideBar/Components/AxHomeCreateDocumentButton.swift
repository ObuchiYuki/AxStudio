//
//  AxCreateDocumentButton.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import AppKit
import SwiftEx
import AppKit

private let kIconSize = CGSize(width: 21, height: 21)

final class AxHomeCreateDocumentButton: NSLoadButton {
    var icon: NSImage? = R.Home.Sidebar.cloudDocument { didSet { needsDisplay = true } }
    
    var backgroundColor: NSColor = R.Color.localDocumentColor { didSet { needsDisplay = true } }
    
    override var isEnabled: Bool {
        didSet {
            needsDisplay = true
            self.alphaValue = isEnabled ? 1 : 0.3
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isEnabled {
            NSColor.lightGray.setFill()
        } else if isHighlighted {
            self.backgroundColor.shadow(withLevel: 0.1)?.setFill()
        }else{
            self.backgroundColor.setFill()
        }
        NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5).fill()
        
        icon?.draw(in: NSRect(originX: 8, centerY: bounds.center.y, size: kIconSize))
        
        let nsstring = title as NSString
        
        let titleRect = CGRect(originX: 38, centerY: bounds.center.y, size: [bounds.width - 42, bounds.height])
        
        nsstring.draw(
            centerY: titleRect,
            attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12, weight: .medium),
                NSAttributedString.Key.foregroundColor : NSColor.white
            ]
        )
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(28)
        }
    }
}



//
//  +AxNodePreview.swift
//  AxStudio
//
//  Created by yuki on 2021/11/12.
//

import AppKit
import BluePrintKit
import EmeralyUI
import AxComponents
import AxCommand
import AxDocument
import SwiftEx
import AppKit
import EmeralyRender
import Combine

final class AxNodePreviewCellController: AxNodeViewController {
    private let cell = AxNodePreviewCell()
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Set<AnyCancellable>) {
        cell.previewView.node = node
    }
}
 
final private class AxNodePreviewCell: NSLoadView {
    let backgroundLayer = ACTranceparentLayer.animationDisabled()
    let previewView = EMNodePreviewView()
    
    override func layout() {
        super.layout()
        backgroundLayer.frame = bounds
    }
    
    override func magnify(with event: NSEvent) {
        let nextMagnification = self.previewView.magnification + event.magnification * self.previewView.magnification
        self.previewView.magnification = nextMagnification.clamped(0.75...2)
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(previewView)
        self.previewView.magnification = 1.5
        self.previewView.contentInsets = .init(x: 8, y: 16)
        self.previewView.snp.makeConstraints{ make in
            make.centerX.top.bottom.equalToSuperview()
        }
    }
}

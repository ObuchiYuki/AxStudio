//
//  AxHomeSidebarButtonItem.swift
//  AxStudio
//
//  Created by yuki on 2021/09/22.
//

import AxComponents
import AppKit
import SwiftEx
import AppKit
import Combine

final class AxHomeSidebarButtonItem: ACSidebarItem {
    let cellHeight: CGFloat = 36
    let isSelectable: Bool = false
    var actionPublisher: AnyPublisher<Void, Never> { self.buttonView.button.actionPublisher.eraseToAnyPublisher() }

    private let buttonView = AxHomeSidebarButtonView()
    
    convenience init(title: String) {
        self.init()
        self.buttonView.button.title = title
    }
    
    func makeCell(_ tableView: NSTableView, at row: Int) -> NSView { buttonView }
}

final private class AxHomeSidebarButtonView: NSLoadView {
    let button = ACColorFillButton()
    
    override func onAwake() {
        self.addSubview(button)
        
        self.button.fillColor = NSColor.controlBackgroundColor.shadow(withLevel: 0.4)!
        self.button.snp.makeConstraints{ make in
            make.height.equalTo(28)
            make.centerY.right.left.equalToSuperview()
        }
    }
}

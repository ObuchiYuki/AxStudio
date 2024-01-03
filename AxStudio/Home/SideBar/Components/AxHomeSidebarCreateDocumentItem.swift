//
//  ACCreateDocumentSidebarItem.swift
//  AxStudio
//
//  Created by yuki on 2021/09/14.
//

import AppKit
import AxComponents
import SwiftEx
import AppKit

final class AxHomeSidebarCreateDocumentItem: ACSidebarItem {
    let cellHeight: CGFloat = 36
    let isSelectable: Bool = false
    let cell = AxHomeCreateDocumentCell()
        
    init(title: String, icon: NSImage, color: NSColor) {
        self.cell.button.backgroundColor = color
        self.cell.button.title = title
        self.cell.button.icon = icon
    }
    
    func makeCell(_ tableView: NSTableView, at row: Int) -> NSView { cell }
}

final class AxHomeCreateDocumentCell: NSLoadView {
    let button = AxHomeCreateDocumentButton()
    
    override func onAwake() {
        self.addSubview(button)
        self.button.snp.makeConstraints{ make in
            make.right.left.centerY.equalToSuperview()
        }
    }
}


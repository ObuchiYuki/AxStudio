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
    
    init(documentType: AxHomeDocument.DocumentType) {
        switch documentType {
        case .local:
            self.cell.button.backgroundColor = R.Color.localDocumentColor
            self.cell.button.title = "ローカルドキュメント"
            self.cell.button.icon = R.Home.Sidebar.localDocument
        case .cloud:
            self.cell.button.backgroundColor = R.Color.cloudDocumentColor
            self.cell.button.title = "クラウドドキュメント"
            self.cell.button.icon = R.Home.Sidebar.cloudDocument
        }
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


//
//  +AxTableEditorView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/22.
//

import SwiftEx
import AppKit
import TableUI

final class AxTableEditorViewController: TBTableViewController {
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        
        document.$selectedTable.compactMap{ $0 }
            .sink{[unowned self] in self.setState($0.model, for: .tableModel) }.store(in: &objectBag)
            
    }
}

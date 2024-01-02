//
//  +AxDebugDCInfoCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/09.
//

import AxComponents
import AppKit
import AxDocument

final class AxDebugDCInfoCellController: NSViewController {
    private let cell = AxDebugDCInfoCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        self.cell.sessionIDLabel.stringValue = debugModel.document.session.sessionID.description
        self.cell.documentIDLabel.stringValue = client.documentID
    }
}

final private class AxDebugDCInfoCell: ACGridView {
    private let sessionIDTitle = ACAreaLabel_(title: "SessionID:", alignment: .right, displayType: .valueName)
    let sessionIDLabel = ACAreaLabel_(title: "XXXXXXXXXXXXXXXX", displayType: .codeValue)
    
    private let documentIDTitle = ACAreaLabel_(title: "DocumentID:", alignment: .right, displayType: .valueName)
    let documentIDLabel = ACAreaLabel_(title: "XXXXXXXXXXXXXXXX", displayType: .codeValue)
    
    override func onAwake() {
        self.rowSpacing = 4

        self.addItem3(sessionIDTitle, row: 0, column: 0)
        self.addItem3(sessionIDLabel, row: 0, column: 1, length: 2)
        
        self.addItem3(documentIDTitle, row: 1, column: 0)
        self.addItem3(documentIDLabel, row: 1, column: 1, length: 2)
    }
}


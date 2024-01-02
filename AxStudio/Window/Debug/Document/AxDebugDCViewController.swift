//
//  AxDebugDCViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/09.
//

import AppKit
import AxComponents
import AxDocument

final class AxDebugDCViewController: ACStackViewController_ {
    
    let headerCell = ACStackViewHeaderCellController_(title: "Document", style: .ultraLarge)
    let infomationHeaderCell = ACStackViewHeaderCellController_(title: "Infomation", style: .large)
    let infomationCell = AxDebugDCInfoCellController()
    
    let debugInfoHeaderCell = ACStackViewHeaderCellController_(title: "Debug", style: .large)
    let debugInfoCell = AxDebugDebugIndoCellController()
    
    override func viewDidLoad() {
        self.stackView.edgeInsets = .init(x: 8, y: 12)
        self.scrollView.drawsBackground = true
        
        self.addCell(headerCell)
        self.addCell(infomationHeaderCell)
        self.addCell(infomationCell)
        
        self.addCell(debugInfoHeaderCell)
        self.addCell(debugInfoCell)
    }
}

final class AxDebugDebugIndoCellController: NSViewController {
    private let cell = AxDebugDebugIndoCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
            debugModel.document.rootNode.appFile.debugInfo.$allowsEmptyScreen
            .sink{[unowned self] in
                cell.allowEmptyScreenCheck.checkState = .identical($0)
            }
            .store(in: &objectBag)
        
        cell.allowEmptyScreenCheck.checkPublisher
            .sink{[unowned self] v in
                debugModel.document.execute { debugModel.document.rootNode.appFile.debugInfo.allowsEmptyScreen = v }
            }
            .store(in: &objectBag)
    }
}

final private class AxDebugDebugIndoCell: ACGridView {
    let allowEmptyScreenCheck = ACCheckBoxAndTitle(title: "Allow empty screen")
    
    override func onAwake() {
        self.addItem3(allowEmptyScreenCheck, row: 0, column: 0, length: 3)
    }
}

//
//  +AxAppDebugCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/11.
//

import AppKit
import BluePrintKit
import DesignKit
import AxComponents

final class AxAppDebugCellController: NSViewController {
    private let cell = AxAppDebugCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        
        cell.assetButton.actionPublisher
            .sink{
                let document = try! NSDocumentController.shared.makeUntitledDocument(ofType: "com.axstudio.imageasset")
                document.makeWindowControllers()
                document.showWindows()
            }
            .store(in: &objectBag)
        
    }
}
 
final private class AxAppDebugCell: ACGridView {
    let nodePickerButton = ACTitleButton_(title: "Node")
    let assetButton = ACTitleButton_(title: "Asset")
    
    override func onAwake() {
        self.addItem3(nodePickerButton, row: 0, column: 0)
        self.addItem3(assetButton, row: 0, column: 1)
    }
}

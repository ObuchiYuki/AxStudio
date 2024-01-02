//
//  +AxButtonCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import SwiftEx
import AxComponents
import STDComponents
import AxCommand
import BluePrintKit

final class AxButtonCellController: NSViewController {
    private let cell = AxButtonCell()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        let button = document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first as? STDButton }
        
        button.switchToLatest{ $0.$action }
            .sink{[unowned self] in
                self.cell.actionTip.setDynamicAction($0)
                self.cell.editActionButton.setDynamicAction($0)
            }
            .store(in: &objectBag)
        
        cell.editActionButton.actionPublisher
            .sink{[unowned self] in
                guard let button = document.selectedLayers.first as? STDButton else { return __warn_ifDebug_beep_otherwise() }
                document.execute(AxEditBluePrintCommand(button.action))
            }
            .store(in: &objectBag)
        
        cell.actionTip.commandPublisher
            .sink{[unowned self] in
                guard let button = document.selectedLayers.first as? STDButton else { return __warn_ifDebug_beep_otherwise() }
                document.execute(AxDynamicActionPropertyCommand($0, button, \STDButton.action))
            }
            .store(in: &objectBag)
    }
}

final private class AxButtonCell: ACGridView {
    let actionTitle = ACAreaLabel_(title: "Action")
    let actionTip = ACDynamicActionTip.autoconnect()
    let editActionButton = ACDynamicActionWell()
    
    override func onAwake() {
        self.addItem3(actionTitle, row: 0, column: 0)
        self.addItem3(editActionButton, row: 0, column: 1, length: 2, decorator: actionTip)
    }
}


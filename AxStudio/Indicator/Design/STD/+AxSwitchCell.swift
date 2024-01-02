//
//  +AxSwitchCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import SwiftEx
import AxComponents
import STDComponents
import AxCommand
import BluePrintKit

final class AxSwitchCellController: NSViewController {
    private let cell = AxSwitchCell()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        let switches = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? STDSwitch } }
        let switchValue = switches.dynamicProperty(\.$on, document: document).removeDuplicates()
        
        switchValue
            .sink{[unowned self] in cell.onCheck.checkbox.setDynamicState($0) }.store(in: &objectBag)
        switchValue
            .sink{[unowned self] in cell.onTip.setDynamicState($0) }.store(in: &objectBag)
        
        self.cell.onCheck.checkPublisher
            .sink{[unowned self] in document.execute(AxSwitchToggleOnCommand($0)) }.store(in: &objectBag)
        self.cell.onCheck.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDSwitch.on)) }.store(in: &objectBag)
        self.cell.onTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "switch on", \STDSwitch.on)) }.store(in: &objectBag)
    }
}

final private class AxSwitchCell: ACGridView {
    let onTip = ACDynamicTip.autoconnect(.bool, dynamic: false)
    let onCheck = ACCheckBoxAndTitle(title: "Switch is on", stateDrop: true)
    
    override func onAwake() {
        self.addItem3(onCheck, row: 0, column: 0, length: 3, decorator: onTip)
    }
}

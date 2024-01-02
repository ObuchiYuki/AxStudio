//
//  +AxCustomStateCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import AxCommand
import SwiftEx
import AppKit
import AxComponents
import BluePrintKit

final class AxStateInfoCellController: NSViewController {
    private let cell = AxCustomStateCell()
    override func loadView() { view = cell }
    
    override func chainObjectDidLoad() {
        cell.typeWell.library = document.typePickerLibrary
        
        let state = document.$selectedState.compactMap{ $0 }
        let componentState = state.map{ $0 as? BPComponentState }
        
        state.switchToLatest{ $0.$name }
            .sink{[unowned self] in cell.nameField.fieldState = .identical($0) }.store(in: &objectBag)
        state.switchToLatest{ $0.$type }
            .sink{[unowned self] in cell.typeWell.type = $0; cell.valueWell.type = $0 }.store(in: &objectBag)
        state.switchToLatest{ $0.$initialValue }
            .sink{[unowned self] in cell.valueWell.value = $0 }.store(in: &objectBag)
        componentState
            .sink{[unowned self] in cell.showBindingControl = $0 != nil }.store(in: &objectBag)
        componentState.compactMap{ $0 }.switchToLatest{ $0.$binding }
            .sink{[unowned self] in cell.bindingTip.checkState = .identical($0) }.store(in: &objectBag)
        
        cell.nameField.endPublisher
            .sink{[unowned self] in document.execute(AxRenameStateCommand($0)) }.store(in: &objectBag)
        cell.valueWell.valuePublisher.compactMap{ $0 } // non nil
            .sink{[unowned self] in document.execute(AxUpdateStateValueCommand($0)) }.store(in: &objectBag)
        cell.typeWell.typePublisher
            .sink{[unowned self] in document.execute(AxUpdateStateTypeCommand($0)) }.store(in: &objectBag)
        cell.bindingTip.checkPublisher
            .sink{[unowned self] in document.execute(AxUpdateStateBindingCommand($0)) }.store(in: &objectBag)
    }
}


final private class AxCustomStateCell: ACGridView {
    let nameTitle = ACAreaLabel_(title: "Name", alignment: .right)
    let nameField = ACTextField_()
    
    let typeTitle = ACAreaLabel_(title: "Type", alignment: .right)
    let typeWell = ACTypeWell()
    
    let valueTitle = ACAreaLabel_(title: "Initial Value", alignment: .right)
    let valueWell = ACValueWell_()
    
    var showBindingControl = false {
        didSet {
            self.bindingTip.isHidden = !showBindingControl
            self.gridHeight = showBindingControl ? 4 : 3

        }
    }
    
    let bindingTip = ACCheckBoxAndTitle(title: "Publish Value")
        
    override func onAwake() {
        self.addItem3(nameTitle, row: 0, column: 0)
        self.addItem3(nameField, row: 0, column: 1, length: 2)
        self.nameField.showIcon = true
        
        self.addItem3(typeTitle, row: 1, column: 0)
        self.addItem3(typeWell, row: 1, column: 1, length: 2)
        
        self.addItem3(valueTitle, row: 2, column: 0)
        self.addItem3(valueWell, row: 2, column: 1, length: 2)
        
        self.addItem3(bindingTip, row: 3, column: 0, length: 3)
        
        self.valueWell.canSelectNil = false
    }
}

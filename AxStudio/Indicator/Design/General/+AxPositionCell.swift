//
//  +AxPositionCell.swift
//  AxStudio
//
//  Created by yuki on 2022/01/05.
//

import SwiftEx
import AppKit
import AxComponents
import AxCommand
import DesignKit
import BluePrintKit

final class AxPositionCellController: NSViewController {
    private let cell = AxPositionCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let constraints = document.selectedUnmasteredLayersp.map{ $0.map{ $0.constraints } }
        let xPinValue = constraints.dynamicProperty(\.$xPinValue, document: document)
        let yPinValue = constraints.dynamicProperty(\.$yPinValue, document: document)
        let anchor = constraints.switchToLatest{ $0.map{ $0.$anchor }.combineLatest }
        let xPinType = constraints.switchToLatest{ $0.map{ $0.$xPinType }.combineLatest }
        let yPinType = constraints.switchToLatest{ $0.map{ $0.$yPinType }.combineLatest }
            
        anchor.map{ $0.mixture(.origin) }
            .sink{[unowned self] in cell.sizeControl.positionType = $0 }.store(in: &objectBag)
        xPinType.map{ $0.mixture(.value) }
            .sink{[unowned self] in cell.xPositionPicker.positionClassPicker.positionClass = $0 }.store(in: &objectBag)
        yPinType.map{ $0.mixture(.value) }
            .sink{[unowned self] in cell.yPositionPicker.positionClassPicker.positionClass = $0 }.store(in: &objectBag)
        xPinValue
            .sink{[unowned self] in cell.xPositionPicker.setDynamicState($0); cell.xPositionTip.setDynamicState($0) }.store(in: &objectBag)
        yPinValue
            .sink{[unowned self] in cell.yPositionPicker.setDynamicState($0); cell.yPositionTip.setDynamicState($0) }.store(in: &objectBag)
        
        cell.sizeControl.positionPublisher
            .sink{[unowned self] in document.execute(AxAnchorCommand($0)) }.store(in: &objectBag)
        
        cell.xPositionTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Position", \DKLayer.constraints.xPinValue)) }.store(in: &objectBag)
        cell.xPositionPicker.lengthField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxXPinValueCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.xPositionPicker.lengthField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, unmaster: false, \DKLayer.constraints.xPinValue)) }.store(in: &objectBag)
        cell.xPositionPicker.positionClassPicker.positionClassPublisher
            .sink{[unowned self] in document.execute(AxPinTypeCommand($0, axis: .x)) }.store(in: &objectBag)
        cell.yPositionPicker.positionClassPicker.positionClassPublisher
            .sink{[unowned self] in document.execute(AxPinTypeCommand($0, axis: .y)) }.store(in: &objectBag)
        
        cell.yPositionTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Position", \DKLayer.constraints.yPinValue)) }.store(in: &objectBag)
        cell.yPositionPicker.lengthField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxYPinValueCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.yPositionPicker.lengthField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, unmaster: false, \DKLayer.constraints.yPinValue)) }.store(in: &objectBag)
    }
}

final private class AxPositionCell: ACGridView {
    let sizeControl = ACPositionConstraintsControl()
    let xPositionPicker = AxLayoutPositionPicker() => { $0.lengthField.unit = "X" }
    let xPositionTip = ACDynamicTip.autoconnect(.float)
    
    let yPositionPicker = AxLayoutPositionPicker() => { $0.lengthField.unit = "Y" }
    let yPositionTip = ACDynamicTip.autoconnect(.float)
    
    override func onAwake() {
        self.addItem3(ACConstraintsPanel_() => { $0.contentView = sizeControl }, row: 0, column: 0)
        
        self.addItem3(xPositionPicker, row: 0, column: 1, length: 2, decorator: xPositionTip)
        self.addItem3(yPositionPicker, row: 1, column: 1, length: 2, decorator: yPositionTip)
    }
}

final class AxLayoutPositionPicker: NSLoadStackView {
    var isEnabled = true {
        didSet {
            self.lengthField.isEnabled = isEnabled
            self.positionClassPicker.isEnabled = isEnabled
        }
    }
    let lengthField = ACNumberField_(stateDrop: true).stepper()
    let positionClassPicker = ACPositionClassPicker()
    
    func setDynamicState(_ state: ACDynamicState<BPFloat?>) {
        self.lengthField.setDynamicState(state)
        self.lengthField.isEnabled = self.isEnabled
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(AxComponents.R.Size.controlHeight)
        }
        
        self.orientation = .horizontal
        self.spacing = 8
        self.addArrangedSubview(lengthField)
        self.addArrangedSubview(positionClassPicker)
        self.positionClassPicker.snp.makeConstraints{ make in
            make.width.equalTo(21)
        }
    }
}

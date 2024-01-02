//
//  +AxStyleShadowCell.swift
//  AxStudio
//
//  Created by yuki on 2020/05/14.
//  Copyright © 2020 yuki. All rights reserved.
//

import SwiftEx
import AppKit
import AppKit
import AxComponents
import AxDocument
import AxCommand
import DesignKit

final class AxStyleShadowCellController: NSViewController {

    private let cell = AxStyleShadowCell()

    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {

        // MARK: - Input -
        let styledLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKStyleShadowLayerType } }
        let shadowColor = styledLayers.dynamicProperty(\.shadow.$color, document: document).removeDuplicates()
        let shadowRadius = styledLayers.dynamicProperty(\.shadow.$radius, document: document).removeDuplicates()
        
        let shadowOffsetX = styledLayers.dynamicProperty(\.shadow.$offsetX, document: document).removeDuplicates()
        let shadowOffsetY = styledLayers.dynamicProperty(\.shadow.$offsetY, document: document).removeDuplicates()
        
        styledLayers.switchToLatest { $0.map { $0.shadow.$isEnabled }.combineLatest }.map{ $0.mixture }
            .removeDuplicates()
            .sink{[unowned self] in cell.checkBox.checkState = $0 }.store(in: &objectBag)
        
        shadowColor.sink{[unowned self] in cell.colorWell.setDynamicColor($0) }.store(in: &objectBag)
        shadowColor.sink{[unowned self] in cell.hexField.setDynamicState($0) }.store(in: &objectBag)
        shadowColor.sink{[unowned self] in cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        
        shadowOffsetX.sink{[unowned self] in cell.offsetXField.setDynamicState($0) }.store(in: &objectBag)
        shadowOffsetX.sink{[unowned self] in cell.offsetXTip.setDynamicState($0) }.store(in: &objectBag)
        
        shadowOffsetY.sink{[unowned self] in cell.offsetYField.setDynamicState($0) }.store(in: &objectBag)
        shadowOffsetY.sink{[unowned self] in cell.offsetYTip.setDynamicState($0) }.store(in: &objectBag)
        
        shadowRadius
            .sink{[unowned self] in
                cell.radiusField.setDynamicState($0)
            }
            .store(in: &objectBag)
        shadowRadius.sink{[unowned self] in cell.radiusTip.setDynamicState($0) }.store(in: &objectBag)
        
        // MARK: - Output -
        self.cell.checkBox.checkPublisher
            .sink {[unowned self] in execute(AxShadowIsEnabledCommand($0)) }.store(in: &objectBag)
        self.cell.colorWell.colorPublisher
            .sink {[unowned self] in document.session.broadcast(AxShadowColorCommand.fromPhase($0)) }.store(in: &objectBag)
        self.cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        self.cell.colorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        self.cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        
        self.cell.colorTip.commandPublisher
            .sink {[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "shadow color", \DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        self.cell.hexField.valuePublisher
            .sink {[unowned self] in
                let color = DKColor(red: $0.red, green: $0.green, blue: $0.blue, alpha: 1)
                document.session.broadcast(AxShadowColorCommand.once(with: color))
            }.store(in: &objectBag)
        self.cell.hexField.constantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        self.cell.hexField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleShadowLayerType.shadow.color)) }.store(in: &objectBag)
        
        self.cell.offsetXField.phasePublisher
            .sink {[unowned self] in document.session.broadcast(AxShadowOffsetCommand.fromPhase(.x, $0)) }.store(in: &objectBag)
        self.cell.offsetXField.statePublisher
            .sink {[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleShadowLayerType.shadow.offsetX)) }.store(in: &objectBag)
        self.cell.offsetXTip.commandPublisher
            .sink {[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Shadow X Offset", \DKStyleShadowLayerType.shadow.offsetX)) }.store(in: &objectBag)
        
        self.cell.offsetYField.phasePublisher
            .sink {[unowned self] in document.session.broadcast(AxShadowOffsetCommand.fromPhase(.y, $0)) }.store(in: &objectBag)
        self.cell.offsetYField.statePublisher
            .sink {[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleShadowLayerType.shadow.offsetY)) }.store(in: &objectBag)
        self.cell.offsetYTip.commandPublisher
            .sink {[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Shadow Y Offset", \DKStyleShadowLayerType.shadow.offsetY)) }.store(in: &objectBag)
        
        self.cell.radiusField.phasePublisher
            .sink {[unowned self] in document.session.broadcast(AxShadowRadiusCommand.fromPhase($0)) }.store(in: &objectBag)
        self.cell.radiusField.statePublisher
            .sink {[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleShadowLayerType.shadow.radius)) }.store(in: &objectBag)
        self.cell.radiusTip.commandPublisher
            .sink {[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Shadow Radius", \DKStyleShadowLayerType.shadow.radius)) }.store(in: &objectBag)
    }
}

final private class AxStyleShadowCell: ACGridView {

    let checkBox = ACCheckBox_()
    let colorWell = ACColorWell().autoconnectLibrary()
    let hexField = ACHexColorField()
    let colorTip = ACDynamicTip.autoconnect(.color)
    
    let offsetXField = ACNumberField_(stateDrop: true).stepper() => { $0.unit = "X" }
    let offsetXTip = ACDynamicTip.autoconnect(.float)
    let offsetYField = ACNumberField_(stateDrop: true).stepper() => { $0.unit = "Y" }
    let offsetYTip = ACDynamicTip.autoconnect(.float)
    let radiusField = ACNumberField_(stateDrop: true).stepper() => { $0.unit = "Z" }
    let radiusTip = ACDynamicTip.autoconnect(.float)
    

    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.addItem3(colorWell, row: 0, column: 0, decorator: colorTip)
        self.addItem3(hexField, row: 0, column: 1)
        
        self.addItem3(offsetXField, row: 1, column: 0, decorator: offsetXTip)
        self.addItem3(offsetYField, row: 1, column: 1, decorator: offsetYTip)
        self.addItem3(radiusField, row: 1, column: 2, decorator: radiusTip)
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.centerY.equalTo(colorWell)
            make.left.equalTo(R.Size.checkBoxLeft)
        }
    }
}

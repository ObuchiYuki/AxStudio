//
//  +AxStyleSolidFill.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import AxDocument
import AxCommand
import DesignKit
import SwiftEx
import AxComponents

final class AxStyleSolidFillCellController: NSViewController {
    private let cell = AxStyleSolidFillCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let styledLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKStyleSolidFillLayerType } }
        
        let shadowColor = styledLayers.dynamicProperty(\.solidFill.$color, document: document).removeDuplicates()
        
        shadowColor.sink{[unowned self] in cell.colorWell.setDynamicColor($0) }.store(in: &objectBag)
        shadowColor.sink{[unowned self] in cell.hexField.setDynamicState($0) }.store(in: &objectBag)
        shadowColor.sink{[unowned self] in cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        
        styledLayers.switchToLatest { $0.map { $0.solidFill.$isEnabled }.combineLatest }.map{ $0.mixture }
            .removeDuplicates()
            .sink{[unowned self] in cell.checkBox.checkState = $0 }.store(in: &objectBag)
        
        self.cell.checkBox.checkPublisher
            .sink {[unowned self] in execute(AxToggleSolidFillIsEnabledCommand($0)) }.store(in: &objectBag)
        
        self.cell.colorWell.colorPublisher
            .sink {[unowned self] in document.execute(AxSolidFillColorCommand($0)) }.store(in: &objectBag)
        self.cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
        self.cell.colorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
        self.cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
        
        self.cell.hexField.valuePublisher
            .sink {[unowned self] in document.execute(AxSolidFillColorCommand(.pulse(DKColor(rgb: $0, alpha: 1)))) }.store(in: &objectBag)
        self.cell.hexField.constantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
        self.cell.hexField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
        
        self.cell.colorTip.commandPublisher
            .sink {[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Tint Color", \DKStyleSolidFillLayerType.solidFill.color)) }.store(in: &objectBag)
    }
}

final private class AxStyleSolidFillCell: ACGridView {
    let checkBox = ACCheckBox_()
    let hexField = ACHexColorField()
    let colorTip = ACDynamicTip.autoconnect(.color)
    let colorWell = ACColorWell().autoconnectLibrary()
    
    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.addItem3(colorWell, row: 0, column: 0, decorator: colorTip)
        self.addItem3(hexField, row: 0, column: 1)
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(R.Size.checkBoxLeft)
            make.centerY.equalTo(colorWell)
        }
    }
}


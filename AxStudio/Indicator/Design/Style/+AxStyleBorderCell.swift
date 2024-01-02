//
//  +AxBorderCell.swift
//  AxStudio
//
//  Created by yuki on 2020/05/14.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxComponents
import DesignKit
import AxDocument
import AxCommand
import SwiftEx
import AppKit

class AxStyleBorderCellController: NSViewController {

    private let cell = AxStyleBorderCell()
    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        // MARK: - Input -
        let borders = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKStyleBorderLayerType }?.map{ $0.border } }
        
        borders.switchToLatest{ $0.map{ $0.$isEnabled }.combineLatest }.map{ $0.mixture }
            .sink{[unowned self] in cell.checkBox.checkState = $0 }.store(in: &objectBag)
        
        let borderColor = borders.dynamicProperty(\.$color, document: document).removeDuplicates()
        let borderWidth = borders.dynamicProperty(\.$width, document: document).removeDuplicates()
        
        borderColor.sink{[unowned self] in cell.colorWell.setDynamicColor($0) }.store(in: &objectBag)
        borderColor.sink{[unowned self] in cell.hexField.setDynamicState($0) }.store(in: &objectBag)
        borderColor.sink{[unowned self] in cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        
        borderWidth.sink{[unowned self] in cell.widthField.setDynamicState($0) }.store(in: &objectBag)
        borderWidth.sink{[unowned self] in cell.widthTip.setDynamicState($0) }.store(in: &objectBag)
        
        // MARK: - Output -
        cell.checkBox.checkPublisher
            .sink{[unowned self] in execute(AxBorderIsEnabledCommand(isEnabled: $0)) }.store(in: &objectBag)
        
        cell.colorWell.colorPublisher
            .sink{[unowned self] in
                document.session.broadcast(AxBorderColorCommand.fromPhase($0))
            }.store(in: &objectBag)
        cell.colorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleBorderLayerType.border.color)) }.store(in: &objectBag)
        cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleBorderLayerType.border.color)) }.store(in: &objectBag)
        cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\DKStyleBorderLayerType.border.color)) }.store(in: &objectBag)
        cell.colorTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Border Color", \DKStyleBorderLayerType.border.color)) }
            .store(in: &objectBag)
        
        cell.hexField.valuePublisher
            .sink{[unowned self] (red, green, blue) in document.session.broadcast(AxBorderColorCommand.once(with: DKColor(red: red, green: green, blue: blue, alpha: 1))) }
            .store(in: &objectBag)
        cell.hexField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleBorderLayerType.border.color)) }.store(in: &objectBag)
        cell.hexField.constantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKStyleBorderLayerType.border.color)) }.store(in: &objectBag)
        cell.widthField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxBorderWidthCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.widthField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKStyleBorderLayerType.border.width)) }.store(in: &objectBag)
        cell.widthTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Border Width", \DKStyleBorderLayerType.border.width)) }.store(in: &objectBag)
    }
}

final private class AxStyleBorderCell: ACGridView {
    let checkBox = ACCheckBox_()
    let colorWell = ACColorWell().autoconnectLibrary()
    
    let colorTip = ACDynamicTip.autoconnect(.color)
    
    let hexField = ACHexColorField()
    let widthField = ACNumberField_(stateDrop: true).stepper() => { $0.unit = "W" }
    let widthTip = ACDynamicTip.autoconnect(.float)

    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.addItem3(colorWell, row: 0, column: 0, decorator: colorTip)
        self.addItem3(hexField, row: 0, column: 1)
        
        self.addItem3(widthField, row: 0, column: 2, decorator: widthTip)
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.centerY.equalTo(colorWell)
            make.left.equalTo(R.Size.checkBoxLeft)
        }
    }
}

extension R.Size {
    static let checkBoxStackLeft: CGFloat = 46
    static let checkBoxLeft: CGFloat = 18
}

extension ACColorWell {
    func autoconnectLibrary() -> ACColorWell {
        self.publisher(for: \.window).first(where: { $0 != nil })
            .sink{[unowned self] _ in self.library = document?.documentColorLibrary }.store(in: &objectBag)
        
        return self
    }
}

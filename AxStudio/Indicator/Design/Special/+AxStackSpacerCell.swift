//
//  +AxStackSpacerCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/05.
//

import AppKit
import SwiftEx
import AppKit
import AxCommand
import DesignKit
import AxComponents

final class AxStackSpacerCellController: NSViewController {
    private let cell = AxStackSpacerCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let spacers = document.$selectedLayers.compactMap{ $0.compactAllSatisfy{ $0 as? DKStackSpacer } }
        let minSpacing = spacers.dynamicProperty(\.$minSpacing, document: document)
        
        minSpacing.sink{[unowned self] in cell.spacingField.setDynamicState($0) }.store(in: &objectBag)
        minSpacing.sink{[unowned self] in cell.spacingTip.setDynamicState($0) }.store(in: &objectBag)
        
        
        cell.spacingField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxSpacerSpacingComand.fromPhase($0)) }.store(in: &objectBag)
        cell.spacingTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Spacing", \DKStackSpacer.minSpacing)) }.store(in: &objectBag)
    }
}

private class AxStackSpacerCell: ACGridView {
    let spacingLabel = ACAreaLabel_(title: "Min Spacing")
    let spacingField = ACNumberField_().slider()
    let spacingTip = ACDynamicTip.autoconnect(.float)
    
    override func onAwake() {
        self.addItem3(spacingLabel, row: 0, column: 0)
        self.addItem3(spacingField, row: 0, column: 1, decorator: spacingTip)
    }
}

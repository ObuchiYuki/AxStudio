//
//  +AxOpacityCell.swift
//  AxStudio
//
//  Created by yuki on 2020/05/14.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxComponents
import AxDocument
import SwiftEx
import AppKit
import AxCommand
import DesignKit
import Neontetra
import BluePrintKit

class AxOpacityCellController: NSViewController {

    private let cell = AxOpacityCell()

    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        let opacity = document.selectedUnmasteredLayersp.dynamicProperty(\.$opacity, document: document)
            .removeDuplicates()
        
        opacity
            .sink{[unowned self] in cell.opacitySlider.setDynamicState($0) }.store(in: &objectBag)
        opacity.map{ $0.map{ $0.map{ BPFloat(round($0.value * 100)) } }}
            .sink{[unowned self] in cell.opacityField.setDynamicState($0) }.store(in: &objectBag)
        opacity
            .sink{[unowned self] in cell.opacityTip.setDynamicState($0) }.store(in: &objectBag)
        // MARK: - Output -
        cell.opacitySlider.valuePublisher
            .sink{[unowned self] in document.session.broadcast(AxOpacityCommand.fromPhase($0.map{ .to($0) })) } .store(in: &objectBag)
        cell.opacitySlider.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKLayer.opacity)) }.store(in: &objectBag)
        cell.opacityField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxOpacityCommand.fromPhase($0.map{ $0.map{ $0 / 100 } })) } .store(in: &objectBag)
        cell.opacityField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKLayer.opacity)) }.store(in: &objectBag)
        cell.opacityTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "opacity", \DKLayer.opacity)) } .store(in: &objectBag)
    }
}

private class AxOpacityCell: ACGridView {
    let opacitySlider = ACSlider_(stateDrop: true)
    let opacityField = ACNumberField_(stateDrop: true).stepper() => { $0.unit = "%" }
    let opacityTip = ACDynamicTip.autoconnect(.float)
    
    override func onAwake() {
        self.addItem3(opacitySlider, row: 0, column: 0, length: 2, decorator: opacityTip)
        self.addItem3(opacityField, row: 0, column: 2)
    }
}

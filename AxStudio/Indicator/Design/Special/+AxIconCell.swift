//
//  +AxIconCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import AxComponents
import SwiftEx
import AppKit
import AxDocument
import DesignKit
import BluePrintKit
import AxCommand

final class AxIconCellController: NSViewController {
    private let cell = AxIconCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let iconLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKIconLayer } }
        let icon = iconLayers.dynamicProperty(\.$icon, document: document).removeDuplicates()
        let iconColor = iconLayers.dynamicProperty(\.$color, document: document).removeDuplicates()
        
        icon.sink{[unowned self] in cell.iconWell.setDynamicState($0) }.store(in: &objectBag)
        icon.sink{[unowned self] in cell.iconTip.setDynamicState($0) }.store(in: &objectBag)
        
        iconColor.sink{[unowned self] in cell.colorWell.setDynamicColor($0) }.store(in: &objectBag)
        iconColor.sink{[unowned self] in cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        
        cell.colorWell.library = document.documentColorLibrary
        cell.iconWell.iconPublisher
            .sink{[unowned self] in document.execute(AxUpdateIconCommand($0)) }.store(in: &objectBag)
        cell.iconTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "icon", \DKIconLayer.icon)) }.store(in: &objectBag)
        cell.colorWell.colorPublisher
            .sink{[unowned self] in document.execute(AxUpdateIconColorCommand($0)) }.store(in: &objectBag)
        cell.colorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKIconLayer.color)) }.store(in: &objectBag)
        cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKIconLayer.color)) }.store(in: &objectBag)
        cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\DKIconLayer.color)) }.store(in: &objectBag)
        cell.colorTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "icon color", \DKIconLayer.color)) }.store(in: &objectBag)
    }
}

final private class AxIconCell: ACGridView {
    let titleLabel = ACAreaLabel_(title: "Icon", displayType: .controlName)
    let iconWell = ACIconWell()
    let iconTip = ACDynamicTip.autoconnect(.icon)
    
    let colorWell = ACColorWell()
    let colorTip = ACDynamicTip.autoconnect(.color)
    
    override func onAwake() {
        self.addItem3(titleLabel, row: 0, column: 0)
        self.addItem3(iconWell, row: 0, column: 1, decorator: iconTip)
        self.addItem3(colorWell, row: 0, column: 2, decorator: colorTip)
    }
}

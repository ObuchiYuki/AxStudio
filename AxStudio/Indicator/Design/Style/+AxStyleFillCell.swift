//
//  +AxStyleFillCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/03.
//

import SwiftEx
import Combine
import AppKit
import AxComponents
import AxCommand
import DesignKit

class AxStyleFillCellController: NSViewController {
    private let cell = AxStyleFillCell()
    
    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        document.$selectedGradientStopIndex
            .sink{[unowned self] in cell.colorWell.gradientIndex = $0 }.store(in: &objectBag)
        
        let layers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKStyleFillLayerType } }
        let fills = layers.map{ $0.map{ $0.fill } }
                
        layers.switchToLatest{ $0.map{ $0.fill.$isEnabled }.combineLatest.map{ $0.mixture } }.removeDuplicates()
            .sink{[unowned self] in self.cell.checkBox.checkState = $0 }.store(in: &objectBag)
        
        let fillType = fills.switchToLatest{ $0.map{ $0.$type }.combineLatest }.map{ $0.mixture(.color) }.removeDuplicates()
        let fillColor = fills.dynamicProperty(\.$color, document: document).removeDuplicates()
        let fillGradient = fills.dynamicProperty(\.$gradient, document: document).removeDuplicates()
                
        fillType.sink{[unowned self] in self.cell.colorWell.type = $0 }.store(in: &objectBag)
        fillType.sink{[unowned self] in self.cell.fillType = $0.reduceNil() }.store(in: &objectBag)
        
        fillColor.sink{[unowned self] in self.cell.hexField.setDynamicState($0) }.store(in: &objectBag)
        fillColor.sink{[unowned self] in self.cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        
        
        fillGradient.sink{[unowned self] in self.cell.gradientTip.setDynamicState($0) }.store(in: &objectBag)
        
        fillType.combineLatest(fillColor, fillGradient)
            .sink{[unowned self] type, color, gradient in
                if type == .identical(.gradient) {
                    self.cell.colorWell.setDynamicGradient(gradient)
                } else {
                    self.cell.colorWell.setDynamicColor(color)
                }
            }
            .store(in: &objectBag)
                
        cell.colorWell.typePublisher
            .sink{[unowned self] in execute(AxFillTypeCommand($0)) }.store(in: &objectBag)
        cell.colorWell.colorPublisher
            .sink{[unowned self] in document.execute(AxFillColorCommand($0)) }.store(in: &objectBag)
        cell.colorWell.gradientCommandPublisher
            .sink{[unowned self] in document.execute(AxFillGradientCommand($0)) }.store(in: &objectBag)
        
        cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxFillLinkToColorConstantCommand($0)) }.store(in: &objectBag)
        cell.colorWell.gradientConstantPublisher
            .sink{[unowned self] in document.execute(AxFillLinkToGradientConstantCommand($0)) }.store(in: &objectBag)
        cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxFillUnlinkConstantCommand()) }.store(in: &objectBag)
        
        cell.colorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxFillLinkToColorStateCommand($0)) }.store(in: &objectBag)
        cell.colorWell.gradientStatePublisher
            .sink{[unowned self] in document.execute(AxFillLinkToGradientStateCommand($0)) }.store(in: &objectBag)
        
        cell.colorWell.isShowingPickerPublisher
            .sink{[unowned self] in execute(AxIsShowingFillPickerCommand($0)) }.store(in: &objectBag)
        
        cell.hexField.valuePublisher
            .sink{[unowned self] in document.execute(AxFillColorCommand(.pulse(DKColor(rgb: $0, alpha: 1)))) }.store(in: &objectBag)
        cell.hexField.statePublisher
            .sink{[unowned self] in document.execute(AxFillLinkToColorStateCommand($0)) }.store(in: &objectBag)
        cell.hexField.constantPublisher
            .sink{[unowned self] in document.execute(AxFillLinkToColorConstantCommand($0)) }.store(in: &objectBag)
        
        cell.colorTip.commandPublisher
            .sink{[unowned self] in execute(AxDynamicLayerPropertyCommand($0, "Fill Color", \DKStyleFillLayerType.fill.color)) }.store(in: &objectBag)
        cell.gradientTip.commandPublisher
            .sink{[unowned self] in execute(AxDynamicLayerPropertyCommand($0, "Gradient Color", \DKStyleFillLayerType.fill.gradient)) }.store(in: &objectBag)
        cell.checkBox.checkPublisher
            .sink{[unowned self] in execute(AxToggleFillIsEnabledCommand($0)) }.store(in: &objectBag)
    }
}

private class AxStyleFillCell: ACGridView {
    let checkBox = ACCheckBox_()
    let hexField = ACHexColorField()
    
    let colorTip = ACDynamicTip.autoconnect(.color)
    let gradientTip = ACDynamicTip.autoconnect(.gradient, dynamic: false)
    let colorWell = ACColorWell(options: .defaultWithGradient).autoconnectLibrary()
    
    var fillType: DKFillType? {
        didSet {
            switch fillType {
            case .none:
                tipContainer.contentView = nil
                hexField.isHidden = true
            case .color:
                tipContainer.contentView = colorTip
                hexField.isHidden = false
            case .gradient:
                tipContainer.contentView = gradientTip
                hexField.isHidden = true
            }
        }
    }
    private let tipContainer = NSPlaceholderView()
    
    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.tipContainer.snp.makeConstraints{ make in
            make.height.equalTo(21)
        }
        self.addItem3(colorWell, row: 0, column: 0, decorator: tipContainer)
        self.addItem3(hexField, row: 0, column: 1)
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(R.Size.checkBoxLeft)
            make.centerY.equalTo(colorWell)
        }
    }
}

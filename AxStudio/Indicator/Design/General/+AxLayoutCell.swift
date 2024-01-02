//
//  AxLayoutCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/03.
//

import AppKit
import DesignKit
import SwiftEx
import AxCommand
import AxDocument
import AxComponents
import Combine
import BluePrintKit
import STDComponents

final class AxSizeCellController: NSViewController {
    private let cell = AxLayoutControlCell()
    
    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        let constraints = document.$selectedLayers.map{ $0.map{ $0.constraints } }
        
        let widthType = constraints.switchToLatest{ $0.map{ $0.$widthType }.combineLatest }.map{ $0.mixture(.auto) }
        let heightType = constraints.switchToLatest{ $0.map{ $0.$heightType }.combineLatest }.map{ $0.mixture(.auto) }
        let widthValue = constraints.dynamicProperty(\.$widthValue, document: document)
        let heightValue = constraints.dynamicProperty(\.$heightValue, document: document)
        let weightEnabled = document.$selectedLayers.map{ $0.allSatisfy{ $0.canRemoveWidthConstraints } }
        let heightEnabled = document.$selectedLayers.map{ $0.allSatisfy{ $0.canRemoveHeightConstraints } }
            
        widthValue
            .sink{[unowned self] in cell.widthPicker.setDynamicState($0) }.store(in: &objectBag)
        widthValue
            .sink{[unowned self] in cell.widthTip.setDynamicState($0) }.store(in: &objectBag)
        widthType
            .sink{[unowned self] in cell.widthPicker.sizeClassPicker.sizeClass = $0 }.store(in: &objectBag)
        widthType.map{ $0 == .identical(.value) || $0 == .identical(.ratio) }.combineLatest(weightEnabled)
            .sink{[unowned self] s, e in
                cell.sizeControl.state.width = e ? s ? .selected : .enabled : .disabled
                cell.widthPicker.isEnabled = s
                cell.widthTip.isEnabled = s
            }
            .store(in: &objectBag)
        
        heightValue
            .sink{[unowned self] in cell.heightPicker.setDynamicState($0) }.store(in: &objectBag)
        heightValue
            .sink{[unowned self] in cell.heightTip.setDynamicState($0) }.store(in: &objectBag)
        heightType
            .sink{[unowned self] in cell.heightPicker.sizeClassPicker.sizeClass = $0 }.store(in: &objectBag)
        heightType.map{ $0 == .identical(.value) || $0 == .identical(.ratio) }.combineLatest(heightEnabled)
            .sink{[unowned self] s, e in
                cell.sizeControl.state.height = e ? s ? .selected : .enabled : .disabled
                cell.heightPicker.isEnabled = s
                cell.heightTip.isEnabled = s
            }
            .store(in: &objectBag)

        cell.sizeControl.widthPublisher
            .sink{[unowned self] in document.execute(AxConstraintSizeTypeCommand($0, .width)) }.store(in: &objectBag)
        cell.sizeControl.heightPublisher
            .sink{[unowned self] in document.execute(AxConstraintSizeTypeCommand($0, .height)) }.store(in: &objectBag)
        cell.sizeControl.allPublisher
            .sink{[unowned self] in document.execute(AxConstraintSizeTypeCommand($0, .all)) }.store(in: &objectBag)
        
        cell.widthPicker.lengthField.phasePublisher
            .sink{[unowned self] in document.execute(AxConstraintsWidthValueCommand($0)) }.store(in: &objectBag)
        cell.widthPicker.lengthField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, unmaster: false, \DKLayer.constraints.widthValue)) }.store(in: &objectBag)
        cell.widthPicker.sizeClassPicker.sizeClassPublisher
            .sink{[unowned self] in document.execute(AxConstraintsSizeClassCommand($0, .x)) }.store(in: &objectBag)
        cell.widthTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Width", unmaster: false, \DKLayer.constraints.widthValue)) }.store(in: &objectBag)
        
        cell.heightPicker.lengthField.phasePublisher
            .sink{[unowned self] in document.execute(AxConstraintsHeightValueCommand($0)) }.store(in: &objectBag)
        cell.heightPicker.lengthField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, unmaster: false, \DKLayer.constraints.heightValue)) }.store(in: &objectBag)
        cell.heightPicker.sizeClassPicker.sizeClassPublisher
            .sink{[unowned self] in document.execute(AxConstraintsSizeClassCommand($0, .y)) }.store(in: &objectBag)
        cell.heightTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Height", unmaster: false, \DKLayer.constraints.heightValue)) }.store(in: &objectBag)
    }
}

private class AxLayoutControlCell: ACGridView {
    let sizePanel = ACConstraintsPanel_()
    let sizeControl = ACSizeConstraintsControl()

    let widthTip = ACDynamicTip.autoconnect(.float)
    let widthPicker = AxLayoutLengthPicker()
    
    let heightTip = ACDynamicTip.autoconnect(.float)
    let heightPicker = AxLayoutLengthPicker()

    override func onAwake() {
        self.addItem3(sizePanel, row: 0, column: 0)
        self.sizePanel.contentView = sizeControl
        
        self.addItem3(widthPicker, row: 0, column: 1, length: 2, decorator: widthTip)
        self.widthPicker.lengthField.unit = "W"
        
        self.addItem3(heightPicker, row: 1, column: 1, length: 2, decorator: heightTip)
        self.heightPicker.lengthField.unit = "H"
    }
}

final class AxLayoutLengthPicker: NSLoadStackView {
    var isEnabled = true {
        didSet {
            self.lengthField.isEnabled = isEnabled
            self.sizeClassPicker.isEnabled = isEnabled
        }
    }
    let lengthField = ACNumberField_(stateDrop: true).stepper()
    let sizeClassPicker = ACSizeClassPicker()
    
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
        self.addArrangedSubview(sizeClassPicker)
        self.sizeClassPicker.snp.makeConstraints{ make in
            make.width.equalTo(21)
        }
    }
}

extension DKLayer {
    @objc public var canRemoveWidthConstraints: Bool { true }
    @objc public var canRemoveHeightConstraints: Bool { true }
}

//extension DKImageLayer {
//    public override var canRemoveWidthConstraints: Bool { false }
//    public override var canRemoveHeightConstraints: Bool { false }
//}

//
//  +AxGeometoryCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/01.
//

import AppKit
import AxComponents
import AxDocument
import DesignKit
import SwiftEx
import AppKit
import AxCommand
import Combine

final class AxGeometryCellController: NSViewController {
    private let cell = AxGeometryCell()
    
    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        // MARK: - Input -
        let applyDebouncer = self.document.session.applyDebouncer
        let frame = document.$selectedLayers
            .map { $0.map { $0.framep }.combineLatest.debounce(by: applyDebouncer) }.switchToLatest()
        let origin = frame.map { $0.map { $0.origin } }
        let size = frame.map { $0.map { $0.size } }
        let rotation = document.$selectedLayers.dynamicProperty(\.$rotation, document: document).removeDuplicates()
        
        let isSizeEnabled = document.$selectedLayers.map{ $0.allSatisfy{ $0.userCanResize } }.removeDuplicates()
        let isRotateEnabled = document.$selectedLayers.map{ $0.allSatisfy{ $0.userCanRotate } }.removeDuplicates()
        
        rotation.sink{[unowned self] in cell.rotationField.setDynamicState($0) }.store(in: &objectBag)
        rotation.sink{[unowned self] in cell.rotationTip.setDynamicState($0) }.store(in: &objectBag)
        
        origin.map{ $0.map{ $0.x }.mixture }.removeDuplicates()
            .sink{[unowned self] in cell.xTextField.fieldValue = $0 }.store(in: &objectBag)
        origin.map{ $0.map{ $0.y }.mixture }.removeDuplicates()
            .sink{[unowned self] in cell.yTextField.fieldValue = $0 }.store(in: &objectBag)
        
        size.map { $0.map{ $0.width }.mixture }.removeDuplicates()
            .sink{[unowned self] in cell.widthTextField.fieldValue = $0 }.store(in: &objectBag)
        size.map { $0.map{ $0.height }.mixture }.removeDuplicates()
            .sink{[unowned self] in cell.heightTextField.fieldValue = $0 }.store(in: &objectBag)
        
        isRotateEnabled
            .sink{[unowned self] in cell.rotationField.isHidden = !$0; cell.rotationTip.isEnabled = $0 }.store(in: &objectBag)
        isSizeEnabled
            .sink{[unowned self] in cell.widthTextField.isEnabled = $0; cell.heightTextField.isEnabled = $0 }.store(in: &objectBag)
        
        // MARK: - Output -
        self.cell.xTextField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxMoveCommand.fromPhase(.x, $0)) }.store(in: &objectBag)
        self.cell.yTextField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxMoveCommand.fromPhase(.y, $0)) }.store(in: &objectBag)
        self.cell.widthTextField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxResizeCommand.fromPhase(.x, $0)) }.store(in: &objectBag)
        self.cell.heightTextField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxResizeCommand.fromPhase(.y, $0)) }.store(in: &objectBag)
        self.cell.aspectLockButton.togglePublisher
            .sink{[unowned self] in execute(AxAspectLockCommand(lock: $0)) }.store(in: &objectBag)
        self.cell.alignToolBar.itemPublisher
            .sink{[unowned self] in execute(AxAlignmentCommand($0)) }.store(in: &objectBag)
        self.cell.rotationField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxRotateLayerCommand.fromPhase($0)) }.store(in: &objectBag)
        self.cell.rotationTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "rotation", \DKLayer.rotation)) }.store(in: &objectBag)
    }
}

private class AxGeometryCell: ACGridView {
    
    let alignToolBar = ACButtonGroup_<AxAlignment>()
    
    let xTextField = ACNumberField_().stepper() => { $0.unit = "X" }
    let yTextField = ACNumberField_().stepper() => { $0.unit = "Y" }
    
    let rotationField = ACNumberField_().slider() => { $0.unit = "°" }
    let rotationTip = ACDynamicTip.autoconnect(.float)

    let widthTextField = ACNumberField_().stepper() => { $0.unit = "W" }
    let heightTextField = ACNumberField_().stepper() => { $0.unit = "H" }
    let aspectLockButton = ACImageButton_.toggleLock()

    override func onAwake() {
        self.addItem3(alignToolBar, row: 0, column: 0, length: 3)
        self.alignToolBar.addItems(AxAlignment.allCases)
        
        self.addItem3(xTextField, row: 1, column: 0)
        self.addItem3(yTextField, row: 1, column: 1)
        self.addItem3(rotationField, row: 1, column: 2, decorator: rotationTip)
        
        self.addItem3(widthTextField, row: 2, column: 0)
        self.addItem3(heightTextField, row: 2, column: 1)
                
        self.addSubview(aspectLockButton)
        self.aspectLockButton.snp.makeConstraints{ make in
            make.left.equalTo(widthTextField.snp.right)
            make.right.equalTo(heightTextField.snp.left)
            make.centerY.equalTo(heightTextField)
        }
    }
}

extension AxAlignment: ACImageItem {
    public var image: NSImage {
        switch self {
        case .top: return R.I.Image.Align.top
        case .bottom: return R.I.Image.Align.bottom
        case .right: return R.I.Image.Align.right
        case .left: return R.I.Image.Align.left
        case .horizontal: return R.I.Image.Align.horizontal
        case .vertical: return R.I.Image.Align.vertical
        }
    }
}

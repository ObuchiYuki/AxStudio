//
//  +AxStackCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/26.
//

import AxComponents
import AppKit
import AxDocument
import DesignKit
import AxCommand
import SwiftEx

final class AxStackCellController: NSViewController {
    private let cell = ACStackCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let stackLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKStackLayer } }

        let spacing = stackLayers.switchToLatest{ $0.map{ $0.$spacing }.combineLatest }.map{ $0.mixture(0) }
        let isFixedSpacing = spacing.map{ $0 != .identical(nil) }
        let paddings = stackLayers.switchToLatest{ $0.map{ $0.$padding }.combineLatest }
        let orientation = stackLayers.switchToLatest{ $0.map{ $0.$orientation }.combineLatest }.map{ $0.mixture(.vertical) }

        stackLayers.switchToLatest{ $0.map{ $0.$alignment }.combineLatest }.map{ $0.mixture(.min) }
            .sink{[unowned self] in self.cell.layoutPicker.layoutControl.alignmentType = $0 }.store(in: &objectBag)
        stackLayers.switchToLatest{ $0.map{ $0.$distribution }.combineLatest }.map{ $0.mixture(.min) }
            .sink{[unowned self] in self.cell.layoutPicker.layoutControl.distributionType = $0 }.store(in: &objectBag)
        stackLayers.switchToLatest{ $0.map{ $0.$isMask }.combineLatest }.map{ $0.mixture }
            .sink{[unowned self] in self.cell.maskCheck.checkState = $0 }.store(in: &objectBag)
        spacing
            .sink{[unowned self] in self.cell.spaceField.fieldValue = $0 }.store(in: &objectBag)
        isFixedSpacing
            .sink{[unowned self] in self.cell.spaceField.isHidden = !$0 }.store(in: &objectBag)
        isFixedSpacing
            .sink{[unowned self] in self.cell.spacingTypeButton.selectedMenuItem = $0 ? cell.packedMenuItem : cell.spaceBetweenMenuItem }.store(in: &objectBag)
        spacing.map{ $0.map{ $0 != nil } }
            .sink{[unowned self] in self.cell.layoutPicker.layoutControl.isPackedSpacing = $0 }.store(in: &objectBag)
        orientation
            .sink{[unowned self] in self.cell.oriantationPicker.selectedEnumItem = $0 }.store(in: &objectBag)
        orientation
            .sink{[unowned self] in self.cell.layoutPicker.layoutControl.orientation = $0 }.store(in: &objectBag)
        paddings.map{ $0.map{ $0.minX }.mixture }
            .sink{[unowned self] in self.cell.layoutPicker.minXField.fieldValue = $0 }.store(in: &objectBag)
        paddings.map{ $0.map{ $0.maxX }.mixture }
            .sink{[unowned self] in self.cell.layoutPicker.maxXField.fieldValue = $0 }.store(in: &objectBag)
        paddings.map{ $0.map{ $0.minY }.mixture }
            .sink{[unowned self] in self.cell.layoutPicker.minYField.fieldValue = $0 }.store(in: &objectBag)
        paddings.map{ $0.map{ $0.maxY }.mixture }
            .sink{[unowned self] in self.cell.layoutPicker.maxYField.fieldValue = $0 }.store(in: &objectBag)
        paddings.map{ $0.map{ [$0.minX, $0.maxX, $0.minY, $0.maxY].mixture(0) }.mixture(.identical(0)).flatMap{ $0 } }
            .sink{[unowned self] in self.cell.paddingField.fieldValue = $0.map{ $0 } }.store(in: &objectBag)
        
        self.cell.layoutPicker.layoutControl.alignmentPublisher
            .sink{[unowned self] in document.execute(AxStackLayerAlignmentCommand($0)) }.store(in: &objectBag)
        self.cell.layoutPicker.layoutControl.distributionPublisher
            .sink{[unowned self] in document.execute(AxStackLayerDistributionCommand($0)) }.store(in: &objectBag)
        self.cell.oriantationPicker.itemPublisher
            .sink{[unowned self] in document.execute(AxStackLayerOrientationCommand($0)) }.store(in: &objectBag)
        self.cell.paddingField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerPaddingCommand($0, .all)) }.store(in: &objectBag)
        self.cell.layoutPicker.minXField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerPaddingCommand($0, .minX)) }.store(in: &objectBag)
        self.cell.layoutPicker.maxXField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerPaddingCommand($0, .maxX)) }.store(in: &objectBag)
        self.cell.layoutPicker.minYField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerPaddingCommand($0, .minY)) }.store(in: &objectBag)
        self.cell.layoutPicker.maxYField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerPaddingCommand($0, .maxY)) }.store(in: &objectBag)
        self.cell.spaceField.phasePublisher
            .sink{[unowned self] in document.execute(AxStackLayerSpaceCommand($0)) }.store(in: &objectBag)
        self.cell.maskCheck.checkPublisher
            .sink{[unowned self] in document.execute(AxStackLayerToggleMaskCommand($0)) }.store(in: &objectBag)
        self.cell.addSpscerButton.actionPublisher
            .sink{[unowned self] in document.execute(AxMakeSpacerCommand()) }.store(in: &objectBag)
        
        self.cell.packedMenuItem.setAction {[unowned self] in
            document.execute(AxStackLayerSpacingTypeCommand(packed: true))
        }
        self.cell.spaceBetweenMenuItem.setAction {[unowned self] in
            document.execute(AxStackLayerSpacingTypeCommand(packed: false))
        }
    }
}

final private class ACStackCell: ACGridView {
    let oriantationPicker = ACEnumSegmentedControl<DKStackLayer.Orientation>()
    let paddingField = ACNumberField_().slider() => { $0.unit = "px" }
    
    let layoutPicker = ACStackLayoutPicker()
    
    let spacingTypeButton = ACPopupButton_()
    let packedMenuItem = NSMenuItem(title: "Packed")
    let spaceBetweenMenuItem = NSMenuItem(title: "Space Between")
    let spaceField = ACNumberField_().slider() => { $0.icon = R.Image.stackSpaceHorizontal }
    
    let maskCheck = ACCheckBoxAndTitle(title: "Mask to bounds")
    let addSpscerButton = ACTitleButton_(title: "Spacer")
    
    override func onAwake() {
        self.oriantationPicker.addItems(DKStackLayer.Orientation.allCases)
        self.addItem3(oriantationPicker, row: 0, column: 2)
        
        let paddingPopupButton = ACNumberFieldPopup_()
        for padding in [2, 4, 8, 12, 16, 20, 24, 28, 32, 36, 64] as [CGFloat] {
            paddingPopupButton.addItem("\(Int(padding)) px", for: padding)
        }
        paddingField.additionalControl = paddingPopupButton
        self.addItem3(paddingField, row: 1, column: 2)
        
        self.addItem3(layoutPicker, row: 0, column: 0, length: 2)
        
        self.spacingTypeButton.addItem(packedMenuItem)
        self.spacingTypeButton.addItem(spaceBetweenMenuItem)
        self.addItem3(spacingTypeButton, row: 3.5, column: 0, length: 2)
        self.addItem3(spaceField, row: 3.5, column: 2)
        
        self.addItem3(maskCheck, row: 4.5, column: 0, length: 2)
        self.addItem3(addSpscerButton, row: 4.5, column: 2)
    }
}

extension DKStackLayer.Orientation: ACImageItem {
    public static var allCases: [Self] = [.vertical, .horizontal]

    public var image: NSImage {
        switch self {
        case .vertical: return R.Image.stackVertical
        case .horizontal: return R.Image.stackHorizontal
        }
    }
}

//
//  +AxListCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/20.
//

import SwiftEx
import STDComponents
import AxDocument
import BluePrintKit
import DesignKit
import AxComponents
import AxCommand
import TableUI

final class AxListCellController: NSViewController {
    private let cell = AxListCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let list = document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first as? STDList }
        let spacing = list.switchToLatest{ $0.$spacing }
        let alignment = list.switchToLatest{ $0.$alignment }
        let padding = list.switchToLatest{ $0.$padding }
        let cellLayer = list.switchToLatest{ $0.$cellLayer.compactMap{ $0.value } }.compactMap{ $0.asset?.value }
        
        padding.map{ $0 == nil  }
            .sink{[unowned self] in
                cell.paddingTypePicker.selectedMenuItem = $0 ? cell.autoPaddingItem : cell.manualPaddingItem
                cell.minXField.isHidden = $0
                cell.maxXField.isHidden = $0
                cell.minYField.isHidden = $0
                cell.maxYField.isHidden = $0
                cell.paddingField.isHidden = $0
                cell.gridHeight = $0 ? 6 : 9
            }
            .store(in: &objectBag)
        
        cellLayer
            .sink{[unowned self] in cell.componentWell.componentAsset = $0 }.store(in: &objectBag)
        alignment
            .sink{[unowned self] in cell.alignmentPicker.selectedEnumItem = .identical($0) }.store(in: &objectBag)
        padding.map{ $0?.minX }
            .sink{[unowned self] in cell.minXField.fieldValue = .identical($0) }.store(in: &objectBag)
        padding.map{ $0?.maxX }
            .sink{[unowned self] in cell.maxXField.fieldValue = .identical($0) }.store(in: &objectBag)
        padding.map{ $0?.minY }
            .sink{[unowned self] in cell.minYField.fieldValue = .identical($0) }.store(in: &objectBag)
        padding.map{ $0?.maxY }
            .sink{[unowned self] in cell.maxYField.fieldValue = .identical($0) }.store(in: &objectBag)
        padding.map{ $0.map{ [$0.minX, $0.maxX, $0.minY, $0.maxY].mixture } ?? .identical(nil) }
            .sink{[unowned self] in cell.paddingField.fieldValue = $0 }.store(in: &objectBag)
        spacing
            .sink{[unowned self] in cell.spacingField.fieldValue = .identical($0) }.store(in: &objectBag)
        
        cell.editMasterButton.actionPublisher
            .sink{[unowned self] in
                if let master = document.selectedLayers.firstSome(where: { $0 as? STDList })?.cellLayer.value {
                    document.execute(AxEditMasterCommand(master))
                }
            }
            .store(in: &objectBag)
        
        cell.componentWell.assetPublisher
            .sink{[unowned self] in document.execute(AxListReplaceCellLayerCommand($0)) }.store(in: &objectBag)
        cell.alignmentPicker.itemPublisher
            .sink{[unowned self] in document.execute(AxListAlignmentCommand($0)) }.store(in: &objectBag)
        cell.spacingField.phasePublisher
            .sink{[unowned self] in document.execute(AxListSpacingCommand($0)) }.store(in: &objectBag)
        cell.autoPaddingItem
            .setAction {[unowned self] in document.execute(AxListPaddingTypeCommand(.auto)) }
        cell.manualPaddingItem
            .setAction {[unowned self] in document.execute(AxListPaddingTypeCommand(.manual)) }
        cell.paddingField.phasePublisher
            .sink{[unowned self] in document.execute(AxListPaddingCommand($0, .all)) }.store(in: &objectBag)
        cell.minXField.phasePublisher
            .sink{[unowned self] in document.execute(AxListPaddingCommand($0, .minX)) }.store(in: &objectBag)
        cell.maxXField.phasePublisher
            .sink{[unowned self] in document.execute(AxListPaddingCommand($0, .maxX)) }.store(in: &objectBag)
        cell.minYField.phasePublisher
            .sink{[unowned self] in document.execute(AxListPaddingCommand($0, .minY)) }.store(in: &objectBag)
        cell.maxYField.phasePublisher
            .sink{[unowned self] in document.execute(AxListPaddingCommand($0, .maxY)) }.store(in: &objectBag)
    }
}

extension STDList.Alignment: ACImageItem {
    public static var allCases: [Self] = [.min, .mid, .max]
    
    public var image: NSImage {
        switch self {
        case .min: return R.I.Image.TextAlign.left
        case .mid: return R.I.Image.TextAlign.center
        case .max: return R.I.Image.TextAlign.right
        }
    }
}

final private class AxListCell: ACGridView {
    let componentWell = ACComponentWell()
    let editMasterButton = ACTitleButton_(title: "Edit Master", image: R.Image.editMini)
    let detachButton = ACTitleButton_(title: "Detach", image: R.Image.detachIcon)
    
    let alignmentTitle = ACAreaLabel_(title: "Alignment")
    let alignmentPicker = ACEnumSegmentedControl<STDList.Alignment>()
        
    let spacingTitle = ACAreaLabel_(title: "Spacing")
    let spacingField = ACNumberField_().slider() => { $0.unit = "pt" }
    
    let paddingTitle = ACAreaLabel_(title: "Padding")
    let paddingTypePicker = ACPopupButton_()
    let autoPaddingItem = NSMenuItem(title: "Auto")
    let manualPaddingItem = NSMenuItem(title: "Manual")
    
    let paddingField = ACNumberField_().slider() => { $0.unit = "pt" }
    
    let minXField = ACNumberField_().slider() => { $0.icon = R.Image.paddingMinX }
    let maxXField = ACNumberField_().slider() => { $0.icon = R.Image.paddingMaxX }
    let minYField = ACNumberField_().slider() => { $0.icon = R.Image.paddingMinY }
    let maxYField = ACNumberField_().slider() => { $0.icon = R.Image.paddingMaxY }

    override func onAwake() {
        self.addItem3(componentWell, row: 0, column: 0, length: 3)
        self.addItem2(editMasterButton, row: 2, column: 0)
        self.addItem2(detachButton, row: 2, column: 1)
        self.detachButton.isEnabled = false
        
        self.addItem3(alignmentTitle, row: 3, column: 0)
        self.addItem3(alignmentPicker, row: 3, column: 1, length: 2)
        self.alignmentPicker.addItems(STDList.Alignment.allCases)
        
        self.addItem3(spacingTitle, row: 4, column: 0)
        self.addItem3(spacingField, row: 4, column: 1)
        
        self.addItem3(paddingTitle, row: 5, column: 0)
        self.addItem3(paddingTypePicker, row: 5, column: 1, length: 2)
        self.paddingTypePicker.addItem(autoPaddingItem)
        self.paddingTypePicker.addItem(manualPaddingItem)
        
        self.addItem3(paddingField, row: 6, column: 2)
        
        self.addItem3(minXField, row: 7, column: 0)
        self.minXField.placeholder = "auto"
        self.addItem3(maxXField, row: 7, column: 2)
        self.maxXField.placeholder = "auto"
        self.addItem3(minYField, row: 6, column: 1)
        self.minYField.placeholder = "auto"
        self.addItem3(maxYField, row: 8, column: 1)
        self.maxYField.placeholder = "auto"
    }
}

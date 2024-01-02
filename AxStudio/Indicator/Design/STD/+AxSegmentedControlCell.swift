//
//  +AxSegmentedControlCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/15.
//

import STDComponents
import SwiftEx
import AppKit
import AxComponents
import AxDocument
import BluePrintKit
import AxCommand
import Combine

final class AxSegmentedControlHeaderCellController: ACStackViewFoldHeaderController {
    let addItemButton = ACImageButton_(image: R.Image.lightAddBtton)
    
    override func viewDidLoad() {
        self.insertAttributeView(addItemButton, at: 0)
    }
    
    override func chainObjectDidLoad() {
        let segmentedLayer = document.selectedUnmasteredLayersp.map{ layers in
            layers.count == 1 ? layers.first as? STDSegmentedControl : nil
        }
        
        segmentedLayer
            .sink{[unowned self] in self.addItemButton.isHidden = $0 == nil }.store(in: &objectBag)
        
        addItemButton.actionPublisher
            .sink{[unowned self] in document.execute(AxMakeSegmentedControlItemCommand()) }.store(in: &objectBag)
    }
}

final class AxSegmentedControlCellController: NSViewController {
    private let cell = AxSegmentedControlCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let segmenteds = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? STDSegmentedControl } }
        
        let selectedIndex = segmenteds.dynamicProperty(\.$selectedIndex, document: document).removeDuplicates()
        
        selectedIndex
            .map{ $0.map{ $0.map{ BPFloat(CGFloat($0.value)) } } }
            .sink{[unowned self] in cell.selectedIndexField.setDynamicState($0) }.store(in: &objectBag)
        selectedIndex
            .sink{[unowned self] in cell.selectedIndexTip.setDynamicState($0) }.store(in: &objectBag)
        
        cell.selectedIndexField.deltaPublisher
            .sink{[unowned self] in document.execute(AxSegmentedControlIndexCommand($0)) }.store(in: &objectBag)
        cell.selectedIndexField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDSegmentedControl.selectedIndex)) }.store(in: &objectBag)
        cell.selectedIndexTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Segment Index", \STDSegmentedControl.selectedIndex)) }.store(in: &objectBag)
    }
}

final private class AxSegmentedControlCell: ACGridView {
    private let selectedIndexTitle = ACAreaLabel_(title: "Selected index")
    let selectedIndexField = ACNumberField_(stateDrop: true).stepper()
    let selectedIndexTip = ACDynamicTip.autoconnect(.int, dynamic: false)
    
    override func onAwake() {
        self.addItem3(selectedIndexTitle, row: 0, column: 0, length: 2)
        self.addItem3(selectedIndexField, row: 0, column: 2, decorator: selectedIndexTip)
        self.selectedIndexField.acceptStateTypes = [.int]
    }
}


final class AxSegmentedItemListCellController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    private let listView = NSStackView()
    private var items = [STDSegmentalItem]() { didSet { self.updateItems(oldValue) } }
    private var itemsBag = Set<AnyCancellable>()
    
    override func loadView() {
        self.listView.orientation = .vertical
        self.view = listView
    }
    
    private func updateItems(_ oldValue: [STDSegmentalItem]) {
        oldValue.forEach{ $0.itemCell.removeFromSuperview() }
        itemsBag.removeAll()
        guard let document = self.document else { return }
        
        for (i, item) in items.enumerated() {
            let itemCell = item.itemCell
            itemCell.indexLabel.stringValue = "Segment \(i)"
            
            let items = Just([item])
            let title = items.dynamicProperty(\STDSegmentalItem.$title, document: document)
            title.sink{ itemCell.titleField.setDynamicState($0) }.store(in: &itemsBag)
            title.sink{ itemCell.titleTip.setDynamicState($0) }.store(in: &itemsBag)
            
            itemCell.titleField.endPublisher
                .sink{ document.execute(AxSegmentedControlRenameItemCommand(i, to: $0)) }.store(in: &itemsBag)
            itemCell.titleTip.commandPublisher
                .sink{ document.execute(AxDynamicPropertyCommand($0, item, "segment \(i) title", \STDSegmentalItem.title)) }.store(in: &itemsBag)
            itemCell.removeButton.actionPublisher
                .sink{ document.execute(AxSegmentedControlRemoveItemCommand(i)) }.store(in: &itemsBag)
            
            self.listView.addArrangedSubview(itemCell)
        }
    }
    
    override func chainObjectDidLoad() {
        let segmentedLayer = document.selectedUnmasteredLayersp.compactMap{ layers in
            layers.count == 1 ? layers.firstSome(where: { $0 as? STDSegmentedControl }) : nil
        }
        segmentedLayer.switchToLatest{ $0.$items }
            .sink{[unowned self] in items = $0 }.store(in: &objectBag)
    }
}

extension STDSegmentalItem {
    fileprivate var itemCell: AxSegmentedItemCell {
        localCache("item.cell", AxSegmentedItemCell())
    }
}

final private class AxSegmentedItemCell: ACGridView {
    let indexLabel = ACAreaLabel_()
    let titleTip = ACDynamicTip.autoconnect(.string)
    let titleField = ACTextField_()
    let removeButton = ACTitleButton_()
    
    override func onAwake() {
        self.addItem3(indexLabel, row: 0, column: 0)
        self.addItem9(titleField, row: 0, column: 3, length: 5, decorator: titleTip)
        
        self.addItem(removeButton, row: 0, column: 17, columnCount: 20, length: 3)
        self.removeButton.cell = NSButtonCell()
        self.removeButton.image = R.Image.trash
        self.removeButton.isBordered = false
    }
}

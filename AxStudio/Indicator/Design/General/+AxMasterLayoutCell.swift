//
//  +AxMasterLayoutCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/28.
//

import AppKit
import AxComponents
import SwiftEx
import DesignKit
import AxCommand
import Combine
import LayoutEngine

final class AxMasterLayoutCellController: NSViewController {
    
    private let cell = AxMasterLayoutCell()
    @ObservableProperty private var unmaster = false
    
    convenience init(unmaster: Bool) {
        self.init()
        self.unmaster = unmaster
    }
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let master = document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first as? DKMasterLayer }
        let masterConstraints = master.map{ $0.constraints }
        let contentConstraints = master.map{ $0.stackLayer.constraints }
        
        masterConstraints.switchToLatest{ $0.$widthType }.map{ $0 != .auto }.removeDuplicates()
            .sink{[unowned self] in cell.widthPicker.masterFixedWidth = $0 }.store(in: &objectBag)
        masterConstraints.switchToLatest{ $0.$heightType }.map{ $0 != .auto }.removeDuplicates()
            .sink{[unowned self] in cell.heightPicker.masterFixedWidth = $0 }.store(in: &objectBag)
        contentConstraints.switchToLatest{ $0.$widthType }.map{ $0 != .auto }.removeDuplicates()
            .sink{[unowned self] in cell.widthPicker.contentFixedWidth = $0 }.store(in: &objectBag)
        contentConstraints.switchToLatest{ $0.$heightType }.map{ $0 != .auto }.removeDuplicates()
            .sink{[unowned self] in cell.heightPicker.contentFixedWidth = $0 }.store(in: &objectBag)
        
        cell.widthPicker.sizeTypePublisher
            .sink{[unowned self] in document.execute(AxMasterConstraintsCommand($0, operation: .width)) }.store(in: &objectBag)
        cell.heightPicker.sizeTypePublisher
            .sink{[unowned self] in document.execute(AxMasterConstraintsCommand($0, operation: .height)) }.store(in: &objectBag)
    }
}

final private class AxMasterLayoutCell: ACGridView {
    let widthIndicator = NSImageView(image: R.Image.stackLayoutHorizonatl)
    let heightIndicator = NSImageView(image: R.Image.stackLayoutVertical)
    
    let widthPicker = AxMasterLayoutTypePopupButton()
    let heightPicker = AxMasterLayoutTypePopupButton()
        
    override func onAwake() {
        self.addItem(widthPicker, row: 0, column: 1, columnCount: 12, length: 11)
        self.addSubview(widthIndicator)
        self.widthIndicator.snp.makeConstraints{ make in
            make.size.equalTo(21)
            make.right.equalTo(widthPicker.snp.left).inset(-4)
            make.centerY.equalTo(widthPicker)
        }
        
        self.addItem(heightPicker, row: 1, column: 1, columnCount: 12, length: 11)
        self.addSubview(heightIndicator)
        self.heightIndicator.snp.makeConstraints{ make in
            make.size.equalTo(21)
            make.right.equalTo(heightPicker.snp.left).inset(-4)
            make.centerY.equalTo(heightPicker)
        }
    }
}

final private class AxMasterLayoutTypePopupButton: ACPopupButton_ {
    
    var contentFixedWidth = false { didSet { self.updateSelection() } }
    var masterFixedWidth = false { didSet { self.updateSelection() } }
    
    let sizeTypePublisher = PassthroughSubject<AxMasterConstraintsCommand.SizeType, Never>()
    
    private func updateSelection() {
        if contentFixedWidth {
            self.selectedMenuItem = fixedSizeItem
        } else if masterFixedWidth {
            self.selectedMenuItem = freeSizeItem
        } else {
            self.selectedMenuItem = hugContentItem
        }
    }
    
    private let freeSizeItem = NSMenuItem(title: "Free Size")
    private let fixedSizeItem = NSMenuItem(title: "Fixed Size")
    private let hugContentItem = NSMenuItem(title: "Hug Content")
        
    override func onAwake() {
        super.onAwake()
        
        self.addItem(freeSizeItem)
        self.addItem(fixedSizeItem)
        self.addItem(hugContentItem)
        
        freeSizeItem.setAction {[unowned self] in self.sizeTypePublisher.send(.free) }
        fixedSizeItem.setAction {[unowned self] in self.sizeTypePublisher.send(.fixed) }
        hugContentItem.setAction {[unowned self] in self.sizeTypePublisher.send(.hugContent) }
    }
}

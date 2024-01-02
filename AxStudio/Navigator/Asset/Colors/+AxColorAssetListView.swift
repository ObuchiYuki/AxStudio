//
//  +AxAssetColorView.swift
//  AxStudio
//
//  Created by yuki on 2021/12/02.
//

import AppKit
import SwiftEx
import AppKit
import AxComponents
import BluePrintKit
import Combine
import DesignKit
import AxCommand

typealias AxColorAssetType = DKFillType

protocol AxColorAssetItem {
    var colorOption: ACColorWell.Options? { get }
    var canRename: Bool { get }
    var canRemove: Bool { get }
    var assetType: AxColorAssetType { get }
    
    var namep: AnyPublisher<String, Never> { get }
    var colorp: AnyPublisher<BPColor, Never> { get }
    var gradientp: AnyPublisher<BPGradient, Never> { get }
    var gradientStopIndexp: AnyPublisher<Int, Never> { get }
    
    func pasteboardWriter() -> NSPasteboardWriting?
    
    func onUpdateName(_ name: String)
    func onUpdateColor(_ color: Phase<BPColor>)
    func onUpdateGradient(_ gradient: AxGradientCommand)
}

extension AxColorAssetItem {
    var colorp: AnyPublisher<BPColor, Never> { .empty() }
    var gradientp: AnyPublisher<BPGradient, Never> { .empty() }
    var gradientStopIndexp: AnyPublisher<Int, Never> { .empty() } 
    
    func onUpdateName(_ name: String) {}
    func onUpdateColor(_ color: Phase<BPColor>) {}
    func onUpdateGradient(_ gradient: AxGradientCommand) {}
}

class AxColorAssetListViewController: NSViewController {
    
    var assets = [AxColorAssetItem]() { didSet { collectionView.reloadData() } }
    
    private let scrollView = NSScrollView()
    private let collectionView = NSCollectionView_()
    
    open func removeAssets(_ asset: [AxColorAssetItem]) { assertionFailure("Must be override") }
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .return, .enter:
            guard collectionView.selectionIndexPaths.count == 1, let indexPath = collectionView.selectionIndexPaths.first else {
                return super.keyDown(with: event)
            }
            if assets[indexPath.item].canRename {
                self.renameColor(at: indexPath)
            }
        case .delete:
            let assets = collectionView.selectionIndexPaths.map{ self.assets[$0.item] }
            
            if assets.allSatisfy({ $0.canRemove }) {
                removeColors(at: collectionView.selectionIndexPaths)
            }
        default: return super.keyDown(with: event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let indexPath = collectionView.indexPathForItem(at: event.location(in: collectionView)) else {
            return
        }
        if !collectionView.selectionIndexPaths.contains(indexPath) {
            collectionView.selectionIndexPaths = [indexPath]
        }
        
        let assets = collectionView.selectionIndexPaths.map{ self.assets[$0.item] }
        let menu = NSMenu()
        
        if assets.allSatisfy({ $0.canRemove }) {
            menu.addItem("Remove Colors") {
                self.removeColors(at: self.collectionView.selectionIndexPaths)
            }
        }
                
        if collectionView.selectionIndexPaths.count == 1, let indexPath = collectionView.selectionIndexPaths.first {
            if assets.allSatisfy({ $0.canRename }) {
                menu.addItem("Rename Color") { self.renameColor(at: indexPath) }
            }
        }
        menu.popUp(positioning: nil, at: event.location(in: view), in: view)
    }
    
    private func removeColors(at indexPaths: Set<IndexPath>) {
        self.removeAssets(indexPaths.map{ self.assets[$0.item] })
    }
    
    private func renameColor(at indexPath: IndexPath) {
        let item = collectionView.item(at: indexPath) as? AxAssetColorItem
        item?.cell.titleLabel.isEditable = true
        self.view.window?.makeFirstResponder(item?.cell.titleLabel)
    }
    
    override func loadView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.sectionInset = NSEdgeInsets(x: 12, y: 8)
        flowLayout.headerReferenceSize = [100, 8]
        flowLayout.itemSize = [64, 48]
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        
        self.scrollView.documentView = collectionView
        self.scrollView.drawsBackground = false
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isSelectable = true
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.backgroundColors = [.clear]
        self.collectionView.register(AxAssetColorItem.self, forItemWithIdentifier: AxAssetColorItem.identifier)
        
        self.view = scrollView
    }
}

extension AxColorAssetListViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let asset = self.assets[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: AxAssetColorItem.identifier, for: indexPath) as! AxAssetColorItem
        item.objectBag.removeAll()

        if let options = asset.colorOption {
            item.cell.isColorEditable = true
            item.cell.colorWell.options = options
        } else {
            item.cell.isColorEditable = false
        }
        
        item.cell.colorWell.library = ACColorItemLibrary.standard
        item.cell.colorWell.type = .identical(asset.assetType)

        asset.namep
            .sink{[unowned item] in item.cell.titleLabel.stringValue = $0 }.store(in: &item.objectBag)
        asset.colorp
            .sink{[unowned item] in item.cell.colorWell.color = .identical($0) }.store(in: &item.objectBag)
        asset.gradientp
            .sink{[unowned item] in item.cell.colorWell.gradient = .identical($0) }.store(in: &item.objectBag)
        asset.gradientStopIndexp
            .sink{[unowned item] in item.cell.colorWell.gradientIndex = $0 }.store(in: &item.objectBag)
        item.cell.colorWell.colorPublisher
            .sink{ asset.onUpdateColor($0) }.store(in: &item.objectBag)
        item.cell.colorWell.gradientCommandPublisher
            .sink{ asset.onUpdateGradient($0) }.store(in: &item.objectBag)
        item.cell.titleLabel.endEditingStringPublisher
            .sink{ asset.onUpdateName($0) }.store(in: &item.objectBag)
        
        item.cell.titleLabel.endEditingPublisher.sink{[unowned self] in
            $0.isEditable = false
            view.window?.makeFirstResponder(collectionView)
        }
        .store(in: &item.objectBag)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let asset = self.assets[indexPath.item]
        let item = collectionView.item(at: indexPath) as? AxAssetColorItem
        item?.cell.colorWell.cancelMouseEvent()
        
        return asset.pasteboardWriter()
    }
}

final private class NSCollectionView_: NSCollectionView {
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .return, .enter, .delete: self.nextResponder?.keyDown(with: event)
        default: super.keyDown(with: event)
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        ACPicker.close()
    }
}

final class AxAssetColorItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("asset.item")
    
    let cell = AxAssetColorCell()
    
    override var isSelected: Bool { didSet { self.cell.isSelected = isSelected } }
    override func loadView() { self.view = cell }
}

final class AxAssetColorCell: NSLoadView {
    var isSelected = false { didSet { self.needsDisplay = true } }
    var isColorEditable = false {
        didSet {
            self.colorWell.isEnabled = isColorEditable
            self.colorWell.alphaValue = 1
        }
    }
    
    let colorWell = ACColorWell()
    let titleLabel = NSTextField(labelWithString: "Color")
    
    private let selectionView = NSView()
    
    override func updateLayer() {
        self.selectionView.layer?.borderColor = NSColor.controlAccentColor.cgColor
        
        if isSelected {
            self.selectionView.layer?.borderWidth = 2
        } else {
            self.selectionView.layer?.borderWidth = 0
        }
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.masksToBounds = false
        
        self.addSubview(colorWell)
        self.colorWell.setCornerRadius(6)
        self.colorWell.snp.remakeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(24)
            make.top.centerX.equalToSuperview()
        }
        
        self.addSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: 10.5)
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.alignment = .center
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.colorWell.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        self.selectionView.wantsLayer = true
        self.selectionView.layer?.cornerRadius = AxComponents.R.Size.controlCorner + 3.1
        
        self.addSubview(selectionView)
        self.selectionView.snp.makeConstraints{ make in
            make.right.equalTo(colorWell).offset(2)
            make.left.equalTo(colorWell).offset(-2)
            make.top.equalTo(colorWell).offset(-2)
            make.bottom.equalTo(colorWell).offset(2)
        }
    }
}

//
//  +AxLocalColorAssetView.swift
//  AxStudio
//
//  Created by yuki on 2021/12/02.
//

import Combine
import SwiftEx
import AppKit
import BluePrintKit
import AxDocument
import AxCommand
import AxComponents

final class AxLocalColorAssetViewController: AxColorAssetListViewController {
    override func removeAssets(_ asset: [AxColorAssetItem]) {
        let constants = asset.compactMap{ $0.refconstant }
        document.execute(AxRemoveColorConstantsCommand(constants))
    }
    override func chainObjectDidLoad() {
        let accentAsset = AxConstantColorAsset(constant: document.rootNode.constantStorage.accentColor, document: document, canRename: false, canRemove: false)
        
        document.rootNode.constantStorage.$colors
            .sink{[unowned self] in self.assets = [accentAsset] + $0.map{ $0.assetItem(document) } }
            .store(in: &objectBag)
    }
}

extension BPConstant {
    fileprivate func assetItem(_ document: AxDocument) -> AxColorAssetItem {
        if self.value is BPColor {
            return AxConstantColorAsset(constant: self, document: document, canRename: true, canRemove: true)
        } else if self.value is BPGradient {
            return AxConstantGradientAsset(constant: self, document: document)
        } else {
            assertionFailure("Unkown type BPConstant")
            return AxConstantColorAsset(constant: self, document: document, canRename: true, canRemove: true)
        }
    }
}

extension AxColorAssetItem {
    fileprivate var refconstant: BPConstant? {
        if let asset = self as? AxConstantColorAsset { return asset.constant }
        if let asset = self as? AxConstantGradientAsset { return asset.constant }
        return nil
    }
}

struct AxConstantColorAsset: AxColorAssetItem {
    var colorOption: ACColorWell.Options? { ACColorWell.Options([.color, .opacity]) }
    let canRename: Bool
    let canRemove: Bool
    
    var assetType: AxColorAssetType { .color }
    
    var namep: AnyPublisher<String, Never> { constant.$name.eraseToAnyPublisher() }
    var colorp: AnyPublisher<BPColor, Never> { constant.$value.compactMap{ $0 as? BPColor }.eraseToAnyPublisher() }
    
    fileprivate let constant: BPConstant
    fileprivate let document: AxDocument
    
    func pasteboardWriter() -> NSPasteboardWriting? {
        constant.pasteBoardRefStorage(forType: .bpConstant)
    }
    
    func onUpdateName(_ name: String) {
        document.execute { constant.name = name }
    }
    func onUpdateColor(_ color: Phase<BPColor>) {
        document.execute(AxUpdateColorConstantCommand(color, constant))
    }
    
    init(constant: BPConstant, document: AxDocument, canRename: Bool, canRemove: Bool) {
        assert(constant.value is BPColor)
        self.constant = constant
        self.document = document
        self.canRename = canRename
        self.canRemove = canRemove
    }
}

struct AxConstantGradientAsset: AxColorAssetItem {
    var colorOption: ACColorWell.Options? { ACColorWell.Options([.gradient, .opacity]) }
    
    let canRename: Bool = true
    let canRemove: Bool = true
    
    var assetType: AxColorAssetType { .gradient }
    
    var namep: AnyPublisher<String, Never> { constant.$name.eraseToAnyPublisher() }
    var gradientp: AnyPublisher<BPGradient, Never> { constant.$value.compactMap{ $0 as? BPGradient }.eraseToAnyPublisher() }
    var gradientStopIndexp: AnyPublisher<Int, Never> { constant.$gradientIndex.eraseToAnyPublisher() }
    
    fileprivate let constant: BPConstant
    fileprivate let document: AxDocument
    
    func pasteboardWriter() -> NSPasteboardWriting? {
        constant.pasteBoardRefStorage(forType: .bpConstant)
    }
    
    func onUpdateName(_ name: String) {
        document.execute { constant.name = name }
    }
    func onRemoveItem() {
        document.execute { document.rootNode.constantStorage.colors.removeFirst(where: { $0 === self.constant }) }
    }
    func onUpdateGradient(_ command: AxGradientCommand) {
        document.execute(AxConstantGradientCommand(command, constant: constant))
    }
    
    init(constant: BPConstant, document: AxDocument) {
        assert(constant.value is BPGradient)
        self.constant = constant
        self.document = document
    }
}

//
//  AxAssetStore.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import DesignKit
import Combine
import AxDocument
import SwiftEx
import AppKit
import STDComponents
import AxComponents
import AxCommand
import AxModelCore
import BluePrintKit

final class AxStandardAssetStore {
    var layerAssets = [ACComponentAssetItem]()

    func register(_ layer: DKLayer, with size: CGSize) {
        self.layerAssets.append(AxStandardAssetLayerItem(layer: layer, size: size))
    }
    func register(_ layer: DKLayer, with size: CGSize, event: AxPasteEvent) {
        self.layerAssets.append(AxStandardAssetCommandItem(layer: layer, size: size, event: event))
    }

    static func makeStore(with document: AxDocument) -> AxStandardAssetStore {
        let store = AxStandardAssetStore()
                
        store.register(DKIconLayer.default, with: [20, 20])
        store.register(STDSlider.default, with: [80, 30])
        
        store.register(STDButton.text, with: [100, 32])
        store.register(STDButton.solid, with: [100, 32])
        store.register(STDButton.bordered, with: [100, 32])
        store.register(STDButton.gradient, with: [100, 32])
        store.register(STDButton.iconAndTitle, with: [100, 32])
        store.register(STDButton.icon, with: [32, 32])
        
        store.register(STDSwitch.default, with: [51, 31])
        store.register(STDTextInput.default, with: [97, 34])
        store.register(STDSegmentedControl.default, with: [150, 31])
        store.register(DKStackLayer.verticalStack, with: [100, 100])
        store.register(DKStackLayer.horizontalStack, with: [100, 100])
        store.register(DKStackLayer.listStack, with: [120, 100], event: .makeList)
        
        return store
    }
}

struct AxStandardAssetCommandItem: ACComponentAssetItem {
    let layer: DKLayer?
    let layerSize: AnyPublisher<CGSize, Never>
    let event: AxPasteEvent
    
    init(layer: DKLayer, size: CGSize, event: AxPasteEvent) {
        self.layer = layer
        self.layerSize = Just(size).eraseToAnyPublisher()
        self.event = event
    }
    
    func makePasteboardWriter() -> NSPasteboardWriting? {
        AxPasteEvent.makeList.pasteboardWriter()
    }
}

struct AxStandardAssetLayerItem: ACComponentAssetItem {
    let layer: DKLayer?
    let layerSize: AnyPublisher<CGSize, Never>
    
    init(layer: DKLayer, size: CGSize) {
        self.layer = layer
        self.layerSize = Just(size).eraseToAnyPublisher()
    }
    
    func makePasteboardWriter() -> NSPasteboardWriting? {
        let copyData = DKLayer.CopyData(
            rootID: nil, objectID: nil, masterID: nil, absFrame: nil
        )
        
        let data = self.layer?.pasteboardWriting(
            for: .dkLayer,
            with: copyData
        )
        
        return data
    }
}

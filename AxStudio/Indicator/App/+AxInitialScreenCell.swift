//
//  +AxInitialScreenCell.swift
//  AxStudio
//
//  Created by yuki on 2022/01/01.
//

import AxComponents
import DesignKit
import AxDocument
import AxCommand
import SwiftEx
import AppKit
import Combine
import AxModelCore

final class AxInitialScreenCellController: NSViewController {
    private let cell = AxInitialScreenCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        self.cell.layerWell.layerGenerator = {
            self.document.screens
        }
        
        self.document.rootNode.appFile.$screenSize
            .sink{[unowned self] in cell.layerWell.message = "Screen - \($0.sizeClass.name)" }
            .store(in: &objectBag)
        self.document.rootNode.appFile.$initialScreen
            .sink{[unowned self] in cell.layerWell.wellState = .identical($0?.get(document.session)) }
            .store(in: &objectBag)
        self.cell.layerWell.layerPublisher.compactMap{ $0 as? DKScreen }
            .sink(on: document) {[unowned self] in document.rootNode.appFile.initialScreen = AxModelWeakRef($0) }
            .store(in: &objectBag)
    }
}

final private class AxInitialScreenCell: ACGridView {
    let layerWell = ACLayerWell()
    
    override func onAwake() {
        self.addItem3(layerWell, row: 0, column: 0, length: 3)
        self.gridHeight = 2
    }
}

extension Publisher where Failure == Never {
    public func sink(on document: AxDocument, _ handler:  @escaping (Output) -> ()) -> AnyCancellable {
        self.sink{ v in document.execute{ handler(v) } }
    }
}

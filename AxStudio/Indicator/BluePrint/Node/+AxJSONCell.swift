//
//  +AxJSONCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/11.
//

import BluePrintKit
import SwiftEx
import AppKit
import AxComponents
import Neontetra

final class AxGenericNodeCellController: AxNodeViewController {
    private let cell = AxGenericNodeCell()
    
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        guard let node = node as? BPGenericsNodeType else { return }
        
        cell.typeWell.library = ACCustomSetTypeLibrary(type(of: node).typeCandidates)
        
        node.typep
            .sink{[unowned self] in cell.typeWell.type = $0 }.store(in: &objectBag)
        cell.typeWell.typePublisher
            .sink{[unowned self] v in
                document.execute {
                    node.type = v
                    node.updateTypePublisher.send(v)
                }
            }
            .store(in: &objectBag)
    }
}

final private class AxGenericNodeCell: ACGridView {
    let typeTitle = ACAreaLabel_(title: "Type:", alignment: .right, displayType: .codeValue)
    let typeWell = ACTypeWell()
    
    override func onAwake() {
        self.addItem3(typeTitle, row: 0, column: 0)
        self.addItem3(typeWell, row: 0, column: 1, length: 2)
    }
}

final class AxJSONCellController: AxNodeViewController {
    
    private let cell = AxJSONCell()
    
    override func loadView() {self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        guard let node = node as? BPJSONPathNode else { return }
        
        node.$path
            .sink{[unowned self] in self.cell.pathWell.wellValue = $0; self.cell.pathPreviewView.components = $0 }.store(in: &objectBag)
        cell.pathWell.valuePublisher
            .sink{[unowned self] v in document.execute { node.path = v } }.store(in: &objectBag)
    }
}

final private class AxJSONCell: ACGridView {
    let pathPreviewView = ACJSONPathPreviewView()
    let pathWell = ACJSONPathWell()
    
    override func onAwake() {
        self.addItem3(pathPreviewView, row: 0, column: 0, length: 3)
        self.addItem3(pathWell, row: 1, column: 0, length: 3)
    }
}



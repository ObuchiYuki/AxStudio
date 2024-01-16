//
//  +AxURLParamCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/11.
//

import AxDocument
import SwiftEx
import AppKit
import DesignKit
import BluePrintKit
import AxComponents
import AxCommand
import Combine

final class AxURLParamatorHeaderController: ACStackViewFoldHeaderController {
    private let addStateButton = ACImageButton_(image: R.Image.lightAddBtton)
    
    override func viewDidLoad() {
        self.insertAttributeView(addStateButton, at: 0)
        self.addStateButton.snp.makeConstraints{ make in
            make.size.equalTo(20)
        }
    }
    
    override func chainObjectDidLoad() {
        self.addStateButton.actionPublisher
            .sink{[unowned self] in addState() }.store(in: &objectBag)
    }
    
    private func addState() {
        guard let node = document.currentNodeContainer?.selectedNodes.first as? BPURLBuilderNodeType else { return __warn_ifDebug_beep_otherwise() }
        
        document.execute {[self] in
            let currentSet = Set(node.urlParamators.map{ $0.key })
            let paramKey = Identifier.make(with: .numberPostfix("key", separtor: ""), notContainsIn: currentSet)
            let param = try BPURLParamator.make(key: paramKey, on: document.session)
            node.urlParamators.append(param)
        }
    }
}

final class AxRequestHeadersHeaderController: ACStackViewFoldHeaderController {
    private let addStateButton = ACImageButton_(image: R.Image.lightAddBtton)
    
    override func viewDidLoad() {
        self.insertAttributeView(addStateButton, at: 0)
        self.addStateButton.snp.makeConstraints{ make in
            make.size.equalTo(20)
        }
    }
    
    override func chainObjectDidLoad() {
        self.addStateButton.actionPublisher
            .sink{[unowned self] in addState() }.store(in: &objectBag)
    }
    
    private func addState() {
        guard let node = document.currentNodeContainer?.selectedNodes.first as? BPAdvancedNetworkNode else { return __warn_ifDebug_beep_otherwise() }
        
        document.execute {[self] in
            let currentSet = Set(node.headers.map{ $0.key })
            let paramKey = Identifier.make(with: .numberPostfix("key", separtor: ""), notContainsIn: currentSet)
            
            let header = try BPRequestHeader.make(key: paramKey, on: document.session)
            node.headers.append(header)
        }
    }
}


final class AxURLParamatorListCellController: AxNodeViewController {
    
    private var items = [BPURLParamator]() { didSet { updateItems(oldValue) } }
    private let listView = NSStackView()
    private var itemsBag = Set<AnyCancellable>()
    
    override func loadView() {
        self.listView.orientation = .vertical
        self.view = listView
    }
    
    private func updateItems(_ oldValue: [BPURLParamator]) {
        oldValue.forEach{ $0.itemCell.removeFromSuperview() }
        itemsBag.removeAll()

        for (i, item) in items.enumerated() {
            let cell = item.itemCell
            cell.keyTitle.stringValue = "Key \(i)"
            item.$key
                .sink{ cell.keyField.fieldState = .identical($0) }.store(in: &itemsBag)
            cell.keyField.endPublisher
                .sink{[unowned self] v in self.document.execute { self.updateKey(item, name: v, cell: cell) } }.store(in: &itemsBag)
            cell.removeButton.actionPublisher
                .sink{[unowned self] in self.document.execute { self.removeParamator(item) } }.store(in: &itemsBag)
            self.listView.addArrangedSubview(cell)
        }
    }
    
    private func updateKey(_ item: BPURLParamator, name: String, cell: AxURLParamatorCell) {
        guard let node = self.node as? BPURLBuilderNodeType else { return __warn_ifDebug_beep_otherwise() }
        let currentSet = Set(node.urlParamators.filter{ $0 !== item }.map{ $0.key })
        
        if currentSet.contains(name) {
            let notupdate = item.key
            document.warningPublisher.send(.init(title: "Duplicated URL paramator '\(name)'"))
            cell.keyField.fieldState = .identical(notupdate)
            NSSound.beep()
        } else {
            item.key = name
        }
    }
    
    private func removeParamator(_ item: BPURLParamator) {
        guard let node = self.node as? BPURLBuilderNodeType else { return __warn_ifDebug_beep_otherwise() }
        node.urlParamators.removeFirst(where: { $0 === item })
    }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Set<AnyCancellable>) {
        guard let node = node as? BPURLBuilderNodeType else { return }
        node.urlParamatorsp
            .sink{[unowned self] in self.items = $0 }.store(in: &objectBag)
    }
}

extension BPURLParamator {
    fileprivate var itemCell: AxURLParamatorCell {
        localCache("item.cell", AxURLParamatorCell())
    }
}

final private class AxURLParamatorCell: ACGridView {
    let keyTitle = ACAreaLabel_(title: "Key")
    let keyField = ACTextField_()
    let removeButton = ACTitleButton_()
    
    override func onAwake() {
        self.addItem3(keyTitle, row: 0, column: 0)
        self.addItem9(keyField, row: 0, column: 3, length: 5)
        
        self.addItem(removeButton, row: 0, column: 17, columnCount: 20, length: 3)
        self.removeButton.cell = NSButtonCell()
        self.removeButton.image = R.Image.trash
        self.removeButton.isBordered = false
    }
}



final class AxRequestHeaderListCellController: AxNodeViewController {
    
    private var items = [BPRequestHeader]() { didSet { updateItems(oldValue) } }
    private let listView = NSStackView()
    private var itemsBag = Set<AnyCancellable>()
    
    override func loadView() {
        self.listView.orientation = .vertical
        self.view = listView
    }
    
    private func updateItems(_ oldValue: [BPRequestHeader]) {
        oldValue.forEach{ $0.itemCell.removeFromSuperview() }
        itemsBag.removeAll()

        for (i, item) in items.enumerated() {
            let cell = item.itemCell
            cell.keyTitle.stringValue = "Key \(i)"
            item.$key
                .sink{ cell.keyField.fieldState = .identical($0) }.store(in: &itemsBag)
            cell.keyField.endPublisher
                .sink{[unowned self] v in self.document.execute { self.updateKey(item, name: v, cell: cell) } }.store(in: &itemsBag)
            cell.removeButton.actionPublisher
                .sink{[unowned self] in self.document.execute { self.removeParamator(item) } }.store(in: &itemsBag)
            self.listView.addArrangedSubview(cell)
        }
    }
    
    private func updateKey(_ item: BPRequestHeader, name: String, cell: AxRequestHeaderCell) {
        guard let node = self.node as? BPAdvancedNetworkNode else { return __warn_ifDebug_beep_otherwise() }
        let currentSet = Set(node.headers.filter{ $0 !== item }.map{ $0.key })
        
        if currentSet.contains(name) {
            let notupdate = item.key
            document.warningPublisher.send(.init(title: "Duplicated header '\(name)'"))
            cell.keyField.fieldState = .identical(notupdate)
            NSSound.beep()
        } else {
            item.key = name
        }
    }
    
    private func removeParamator(_ item: BPRequestHeader) {
        guard let node = self.node as? BPAdvancedNetworkNode else { return __warn_ifDebug_beep_otherwise() }
        node.headers.removeFirst(where: { $0 === item })
    }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Set<AnyCancellable>) {
        guard let node = node as? BPAdvancedNetworkNode else { return }
        node.$headers
            .sink{[unowned self] in self.items = $0 }.store(in: &objectBag)
    }
}

extension BPRequestHeader {
    fileprivate var itemCell: AxRequestHeaderCell {
        localCache("item.cell", AxRequestHeaderCell())
    }
}

final private class AxRequestHeaderCell: ACGridView {
    let keyTitle = ACAreaLabel_(title: "Key")
    let keyField = ACTextField_()
    let removeButton = ACTitleButton_()
    
    override func onAwake() {
        self.addItem3(keyTitle, row: 0, column: 0)
        self.addItem9(keyField, row: 0, column: 3, length: 5)
        
        self.addItem(removeButton, row: 0, column: 17, columnCount: 20, length: 3)
        self.removeButton.cell = NSButtonCell()
        self.removeButton.image = R.Image.trash
        self.removeButton.isBordered = false
    }
}








protocol BPURLBuilderNodeType: BPIONode {
    var urlParamators: [BPURLParamator] { get set }
    var urlParamatorsp: AnyPublisher<[BPURLParamator], Never> { get }
}

extension BPNetworkNode: BPURLBuilderNodeType {
    var urlParamatorsp: AnyPublisher<[BPURLParamator], Never> { self.$urlParamators.eraseToAnyPublisher() }
}
extension BPAdvancedNetworkNode: BPURLBuilderNodeType {
    var urlParamatorsp: AnyPublisher<[BPURLParamator], Never> { self.$urlParamators.eraseToAnyPublisher() }
}

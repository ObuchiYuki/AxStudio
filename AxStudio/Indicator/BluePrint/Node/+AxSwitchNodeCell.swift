//
//  +AxSwitchNodeCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/11.
//

import AxDocument
import SwiftEx
import DesignKit
import BluePrintKit
import AxComponents
import AxCommand
import Combine
import AxModelCore

final class AxSwitchNodeHeaderController: ACStackViewFoldHeaderController {
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
        guard let node = document.currentNodeContainer?.selectedNodes.first as? BPSwitchNode else { return __warn_ifDebug_beep_otherwise() }
        
        document.execute {[self] in
            guard let nextValue = makeNextValue(node.type, values: node.cases.map{ $0.value }) else {
                return document.warningPublisher.send(.init(title: "Cannot create new value"))
            }
            
            BPSwitchNode.Case(AxModelRef(node), value: nextValue).makeOnDocument(document)
                .peek{ node.cases.append($0) }.catch(document.handleError)
        }
    }
    
    private func makeNextValue(_ type: BPType, values: [BPValue]) -> BPValue? {
        if type == .string {
            let nameset = Set(values.compactMap{ $0 as? BPString }.map{ $0.value })
            let nextname = Identifier.make(with: .numberPostfix("case", separtor: ""), notContainsIn: nameset)
            return BPString(nextname)
        }
        if type == .int {
            let nextid = values.compactMap{ $0 as? BPInt }.map{ $0.value }.max(0) + 1
            return BPInt(nextid)
        }
        if type == .float {
            let nextid = values.compactMap{ $0 as? BPFloat }.map{ $0.value }.max(0) + 1
            return BPFloat(nextid)
        }
        return nil
    }
}


final class AxSwitchNodeListCellController: AxNodeViewController {
    
    private var items = [BPSwitchNode.Case]() { didSet { updateItems(oldValue) } }
    private let listView = NSStackView()
    private var itemsBag = Set<AnyCancellable>()
    
    override func loadView() {
        self.listView.orientation = .vertical
        self.view = listView
    }
    
    private func updateItems(_ oldValue: [BPSwitchNode.Case]) {
        guard let node = self.node as? BPSwitchNode else { return __warn_ifDebug_beep_otherwise() }
        oldValue.forEach{ $0.itemCell.removeFromSuperview() }
        itemsBag.removeAll()

        for (i, item) in items.enumerated() {
            let cell = item.itemCell
            
            cell.valueTitle.stringValue = "case \(i)"
            node.$type.sink{ cell.valueWell.type = $0 }.store(in: &itemsBag)
            item.$value.sink{ cell.valueWell.value = $0 }.store(in: &itemsBag)
            
            cell.removeButton
                .actionPublisher.sink{[unowned self] in document.execute { removeParamator(item) } }.store(in: &itemsBag)
            cell.valueWell.valuePublisher.compactMap{ $0 }
                .sink{[unowned self] v in document.execute { updateValue(item, value: v, cell: cell) } }.store(in: &itemsBag)
            
            self.listView.addArrangedSubview(cell)
        }
    }
    
    private func updateValue(_ item: BPSwitchNode.Case, value: BPValue, cell: AxSwitchCaseCell) {
        guard let node = self.node as? BPSwitchNode else { return __warn_ifDebug_beep_otherwise() }
        let currentValueSet = node.cases.filter{ $0 !== item }.map{ $0.value }
        
        switch node.type {
        case .string:
            guard let value = value as? BPString else { return __warn_ifDebug_beep_otherwise() }
            
            if currentValueSet.compactMap({ ($0 as? BPString)?.value }).contains(value.value) {
                document.warningPublisher.send(.init(title: "Duplicated case"))
                cell.valueWell.value = item.value
            } else {
                item.value = value
            }
        case .int:
            guard let value = value as? BPInt else { return __warn_ifDebug_beep_otherwise() }
            
            if currentValueSet.compactMap({ ($0 as? BPInt)?.value }).contains(value.value) {
                document.warningPublisher.send(.init(title: "Duplicated case"))
                cell.valueWell.value = item.value
            } else {
                item.value = value
            }
        case .float:
            guard let value = value as? BPFloat else { return __warn_ifDebug_beep_otherwise() }
            
            if currentValueSet.compactMap({ ($0 as? BPFloat)?.value }).contains(value.value) {
                document.warningPublisher.send(.init(title: "Duplicated case"))
                cell.valueWell.value = item.value
            } else {
                item.value = value
            }
        default: return __warn_ifDebug_beep_otherwise()
        }
    }
    
    private func removeParamator(_ item: BPSwitchNode.Case) {
        guard let node = self.node as? BPSwitchNode else { return __warn_ifDebug_beep_otherwise() }
        node.cases.removeFirst(where: { $0 === item })
    }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        guard let node = node as? BPSwitchNode else { return }
        node.$cases
            .sink{[unowned self] in self.items = $0 }.store(in: &objectBag)
    }
}

extension BPSwitchNode.Case {
    fileprivate var itemCell: AxSwitchCaseCell {
        localCache("item.cell", AxSwitchCaseCell())
    }
}

final private class AxSwitchCaseCell: ACGridView {
    let valueTitle = ACAreaLabel_(title: "case 0")
    let valueWell = ACValueWell_()
    let removeButton = ACTitleButton_()
    
    override func onAwake() {
        self.addItem3(valueTitle, row: 0, column: 0)
        self.addItem9(valueWell, row: 0, column: 3, length: 5)
        self.valueWell.canSelectNil = false
        
        self.addItem(removeButton, row: 0, column: 17, columnCount: 20, length: 3)
        self.removeButton.cell = NSButtonCell()
        self.removeButton.image = R.Image.trash
        self.removeButton.isBordered = false
    }
}

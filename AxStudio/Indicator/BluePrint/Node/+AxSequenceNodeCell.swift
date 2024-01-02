//
//  +AxSequenceNodeCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/11.
//

import BluePrintKit
import AxComponents
import SwiftEx
import AppKit
import AxModelCore

final class AxSequenceNodeCellController: AxNodeViewController {
    private let cell = AxSequenceNodeCell()
    
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        guard let node = node as? BPSequenceNode else { return }
        node.$sockets.map{ $0.count }
            .sink{[unowned self] in cell.countField.fieldValue = .identical(CGFloat($0)) }.store(in: &objectBag)
        
        cell.countField.deltaPublisher.map{ $0.map{ Int($0) } }.map{ $0.reduce(node.sockets.count) }
            .sink{[unowned self] in self.udpateCount(to: $0) }.store(in: &objectBag)
    }
    
    private func udpateCount(to count: Int) {
        if count < 2 { return NSSound.beep() }
        guard let node = node as? BPSequenceNode else { return }
        if node.sockets.count < count {
            let delta = count - node.sockets.count
            let newSocketPromsies = (0..<delta).map{_ in
                BPOutputSocketData(node: AxModelRef(node)).make(document.session)
            }
            Promise.combineAll(newSocketPromsies)
                .receive(on: document.execute)
                .peek{ node.sockets.append(contentsOf: $0) }
                .catch(document.handleError)
        } else if node.sockets.count > count {
            document.execute {
                let newSockets = node.sockets[0..<count]
                node.sockets = Array(newSockets)
            }
        }
    }
}

final private class AxSequenceNodeCell: ACGridView {
    let countTitle = ACAreaLabel_(title: "Count")
    let countField = ACNumberField_().stepper()
    
    override func onAwake() {
        self.addItem3(countTitle, row: 0, column: 0)
        self.addItem3(countField, row: 0, column: 1)
    }
}

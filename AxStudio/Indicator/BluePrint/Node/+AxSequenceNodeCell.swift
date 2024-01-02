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
import Combine

final class AxSequenceNodeCellController: AxNodeViewController {
    private let cell = AxSequenceNodeCell()
    
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Set<AnyCancellable>) {
        guard let node = node as? BPSequenceNode else { return }
        node.$sockets.map{ $0.count }
            .sink{[unowned self] in cell.countField.fieldValue = .identical(CGFloat($0)) }.store(in: &objectBag)
        
        cell.countField.deltaPublisher.map{ $0.map{ Int($0) } }.map{ $0.reduce(node.sockets.count) }
            .sink{[unowned self] output in
                self.document.execute{ try self.udpateCount(to: output) }
            }
            .store(in: &objectBag)
    }
    
    private func udpateCount(to count: Int) throws {
        assert(document.session.isExecuting)
        
        if count < 2 { return NSSound.beep() }
        guard let node = node as? BPSequenceNode else { return }
        if node.sockets.count < count {
            let delta = count - node.sockets.count
            let newSockets = try (0..<delta).map{_ in
                try BPOutputSocketData.make(on: document.session) => {
                    $0.node = AxModelRef(node)
                }
            }
            node.sockets.append(contentsOf: newSockets)
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

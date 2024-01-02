//
//  ＋AxNodeInputs.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import BluePrintKit
import SwiftEx
import AppKit
import Combine
import Neontetra
import AxCommand

final class AxNodeInputListController: AxNodeViewController {
    private let cell = AxNodeInputListCell()
    
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        node.inputSocketsp()
            .sink{[unowned self] in cell.sockets = $0 }.store(in: &objectBag)
        
        cell.valuePublisher
            .sink{[unowned self] socket, value in
                document.execute(AxUpdateSocketValue(socket: socket, value: value))                
            }
            .store(in: &objectBag)
    }
}

final class AxNodeInputListCell: NSLoadStackView {
    
    var sockets = [NEInputSocket]() { didSet { self.updateInputs(oldValue) } }
    var valuePublisher: AnyPublisher<(NEInputSocket, BPValue?), Never> { valueSubject.eraseToAnyPublisher() }
    
    private let valueSubject = PassthroughSubject<(NEInputSocket, BPValue?), Never>()
    private var inputsBag = Bag()
    
    private func updateInputs(_ oldValue: [NEInputSocket]) {
        self.subviews = []
        self.inputsBag.removeAll()
        
        for (i, socket) in sockets.enumerated() {
            let cell = socket.inputCell
            self.addArrangedSubview(cell)
            socket.namePublisher.map{ $0 ?? "Input \(i)" }.sink{ cell.title = "\($0): " }.store(in: &inputsBag)
            socket.typePublisher.sink{ cell.type = $0 }.store(in: &inputsBag)
            socket.data.$value
                .sink{ cell.value = $0 }.store(in: &inputsBag)
            
            cell.valuePublisher
                .sink{[unowned self] in self.valueSubject.send((socket, $0)) }.store(in: &inputsBag)
        }
    }
    
    override func onAwake() {
        self.spacing = 8
        self.edgeInsets = .zero
        self.orientation = .vertical
    }
}

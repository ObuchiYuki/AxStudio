//
//  AxDebugWSStackViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents

final class AxDebugWSStackViewController: ACStackViewController_ {
    let headerCell = ACStackViewHeaderCellController_(title: "WebSocket", style: .ultraLarge)
    let connectionHeaderCell = ACStackViewHeaderCellController_(title: "Connection", style: .large)
    let connectionCell = AxDebugWSConnectionCellController()
    
    let reconnectionHeaderCell = ACStackViewHeaderCellController_(title: "Reconnection", style: .large)
    let reconnectionCell = AxDebugWSReconnectionCellController()
    
    let configHeaderCell = ACStackViewHeaderCellController_(title: "Config", style: .large)
    let configCell = AxDebugWSConfigCellController()
    
    let staticsHeaderCell = ACStackViewHeaderCellController_(title: "Statics", style: .large)
    let staticsCell = AxDebugWSStaticsCellController()
    
    override func viewDidLoad() {
        self.stackView.edgeInsets = .init(x: 8, y: 12)
        self.scrollView.drawsBackground = true
        
        self.addCell(headerCell)
        
        self.addCell(connectionHeaderCell)
        self.addCell(connectionCell, spaceAfter: 18)
        
        self.addCell(reconnectionHeaderCell)
        self.addCell(reconnectionCell, spaceAfter: 18)
        
        self.addCell(configHeaderCell)
        self.addCell(configCell)
        
        self.addCell(staticsHeaderCell)
        self.addCell(staticsCell)
    }
}


class AxDebugWSStaticsCellController: NSViewController {
    private let cell = AxDebugWSStaticsCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        cell.toolTip = "Frag"
        
        debugModel.logPublisher
            .sink{[unowned self] in
                let string = $0.string
                if string.contains("\"state\"") {
                    cell.messageBar.stateMessageCount += 0.05
                } else if string.contains("\"frag\"") {
                    cell.messageBar.fragMessageCount += 1
                } else if string.contains("\"add\"") {
                    cell.messageBar.addMessageCount += 10
                } else if string.contains("\"resource\"") {
                    cell.messageBar.meadiMessageCount += 20
                } else if string.contains("\"com\"") {
                    cell.messageBar.commandMessageCount += 0.05
                }
            }
            .store(in: &objectBag)
    }
}

private class AxDebugWSStaticsCell: ACGridView {
    let messageBar = ACMessageBar()
    
    override func onAwake() {
        self.addItem3(messageBar, row: 0, column: 0, length: 3)
    }
}

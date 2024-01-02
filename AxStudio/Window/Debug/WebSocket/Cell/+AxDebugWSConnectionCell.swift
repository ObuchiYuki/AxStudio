//
//  +AxDebugWebSocketConnectionCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import SwiftEx
import AppKit
import AxComponents
import AxDocument
import SocketIO

final class AxDebugWSConnectionCellController: NSViewController {
    private let cell = AxDebugWSConnectionCell()
    private var observerTimer: Timer?
    private var clientPayload: [String: Any]?
        
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }
        
        self.startObserver()
        
        Mirror(reflecting: client.socket).children.forEach{
            if $0.label == "connectPayload", let payload = $0.value as? [String: Any] {
                self.clientPayload = payload
            }
        }
        
        cell.hostField.stringValue = client.manager.socketURL.absoluteString
        cell.namespaceField.stringValue = client.socket.nsp
        cell.connectButton.actionPublisher
            .sink{[unowned self] in
                debugModel.sendLog(type: "Debug", message: "Socket Connection Start", color: .orange)
                client.socket.connect(withPayload: self.clientPayload)
            }.store(in: &objectBag)
        cell.disconnectButton.actionPublisher
            .sink{[unowned self] in
                debugModel.sendLog(type: "Debug", message: "Socket Disconnect Start", color: .orange)
                client.socket.disconnect()
            }.store(in: &objectBag)
    }
    
    private func startObserver() {
        self.observerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            self.updateStatus()
        }
    }
    
    private func updateStatus() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        self.cell.connectedStateField.stringValue = "\(client.socket.status.active)"
    }
    
    deinit {
        self.observerTimer?.invalidate()
    }
}

final private class AxDebugWSConnectionCell: ACGridView {
    private let hostLabel = ACAreaLabel_(title: "SocketURL:", alignment: .right, displayType: .valueName)
    let hostField = ACAreaLabel_(displayType: .codeValue)
    
    private let namespaceLabel = ACAreaLabel_(title: "Namespace:", alignment: .right, displayType: .valueName)
    let namespaceField = ACAreaLabel_(displayType: .codeValue)
    
    private let connectedStateLabel = ACAreaLabel_(title: "Connected:", alignment: .right, displayType: .valueName)
    let connectedStateField = ACAreaLabel_(title: "Unkown", displayType: .codeValue)
    
    private let connectionLabel = ACAreaLabel_(title: "Action:", alignment: .right, displayType: .valueName)
    let connectButton = ACTitleButton_(title: "Connect")
    let disconnectButton = ACTitleButton_(title: "Disconnect")
    
    override func onAwake() {
        self.rowSpacing = 4
        
        self.addItem3(hostLabel,            row: 0, column: 0)
        self.addItem3(hostField,            row: 0, column: 1, length: 2)
        
        self.addItem3(namespaceLabel,       row: 1, column: 0)
        self.addItem3(namespaceField,       row: 1, column: 1, length: 2)
        
        self.addItem3(connectedStateLabel,  row: 2, column: 0)
        self.addItem3(connectedStateField,  row: 2, column: 1)
        
        self.addItem3(connectionLabel,      row: 3, column: 0)
        self.addItem3(connectButton,        row: 3, column: 1)
        self.addItem3(disconnectButton,     row: 3, column: 2)
    }
}


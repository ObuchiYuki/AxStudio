//
//  +AxDebugWSReconnectCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/09.
//

import AppKit
import SwiftEx
import AxComponents
import AxDocument
import SocketIO

final class AxDebugWSReconnectionCellController: NSViewController {
    private let cell = AxDebugWSReconnectionCell()
    private var observerTimer: Timer?

    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        var semaphore: DispatchSemaphore? {
            didSet {
                DispatchQueue.main.async {
                    self.cell.startButton.isEnabled = semaphore != nil
                    self.cell.stopButton.isEnabled = semaphore == nil
                }
            }
        }
        cell.startButton.isEnabled = false
        
        cell.stopButton.actionPublisher
            .sink{
                client.manager.handleQueue = DispatchQueue.global()
                client.manager.reconnect()
            }.store(in: &objectBag)
        
        cell.startButton.actionPublisher
            .sink{ 
                guard let tsemaphore = semaphore else { return }
                
                tsemaphore.signal()
                semaphore = nil
            }.store(in: &objectBag)

        client.socket.on(clientEvent: .reconnect) {[unowned self] data, ark in
            debugModel.sendLog(type: "Debug", message: "Socket Reconnect Wait", color: .orange)
            if semaphore != nil {
                return debugModel.sendLog(type: "Error", message: "Nested reconnect waiting", color: .red)
            }
            semaphore = DispatchSemaphore(value: 0)
            semaphore?.wait()
            self.debugModel.sendLog(type: "Debug", message: "Socket Reconnect Signal", color: .orange)
        }
        
        startObserver()
    }
    
    private func startObserver() {
        self.observerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            self.updateStatus()
        }
    }
    
    private func updateStatus() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        cell.statusLabel.stringValue = "\(client.socket.status)"
    }
    
    deinit {
        self.observerTimer?.invalidate()
    }
}

final private class AxDebugWSReconnectionCell: ACGridView {
    let descriptionTitle = ACAreaLabel_(title: "再接続のテストを行います。Stopで再接続開始・Startで再接続", displayType: .valueName)
    
    private let reconnectionTitle = ACAreaLabel_(title: "Status:", alignment: .right, displayType: .valueName)
    let statusLabel = ACAreaLabel_(title: "Unkown", displayType: .codeValue)
    
    private let reconnectionLabel = ACAreaLabel_(title: "Connection:", alignment: .right, displayType: .valueName)
    let stopButton = ACTitleButton_(title: "Stop")
    let startButton = ACTitleButton_(title: "Start")
    
    override func onAwake() {
        self.rowSpacing = 4
        
        self.addItem3(descriptionTitle,     row: 0, column: 0, length: 3)
        
        self.addItem3(reconnectionTitle,    row: 1, column: 0)
        self.addItem3(statusLabel,          row: 1, column: 1)
        
        self.addItem3(reconnectionLabel,    row: 2, column: 0)
        self.addItem3(stopButton,           row: 2, column: 1)
        self.addItem3(startButton,          row: 2, column: 2)
    }
}


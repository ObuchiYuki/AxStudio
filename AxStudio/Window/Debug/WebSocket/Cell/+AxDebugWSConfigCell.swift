//
//  +AxDebugWSConfigCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//


import AppKit
import SwiftEx
import AxComponents
import AxDocument

final class AxDebugWSConfigCellController: NSViewController {
    private let cell = AxDebugWSConfigCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setUpDelay(.to(UserDefaults.standard.double(forKey: "client.uploadDelay")))
            self.setDownDelay(.to(UserDefaults.standard.double(forKey: "client.downloadDelay")))
        }

        
        client.$uploadDelay
            .sink{[unowned self] in self.cell.updelayField.fieldValue = .identical(CGFloat($0)) }.store(in: &objectBag)
        client.$downloadDelay
            .sink{[unowned self] in self.cell.downdelayField.fieldValue = .identical(CGFloat($0)) }.store(in: &objectBag)

        self.cell.updelayField.phasePublisher
            .sink{[unowned self] phase in
                if let value = phase.value { self.setUpDelay(value.map{ TimeInterval($0) }) }
            }
            .store(in: &objectBag)
        
        self.cell.downdelayField.phasePublisher
            .sink{[unowned self] phase in
                if let value = phase.value { self.setDownDelay(value.map{ TimeInterval($0) }) }
            }
            .store(in: &objectBag)
        
    }
    
    private func setUpDelay(_ delta: Delta<TimeInterval>) {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        client.uploadDelay = delta.map{ TimeInterval($0) }.reduce(client.uploadDelay).clamped(0...)
        debugModel.sendLog(type: "Socket Config", message: "Upload delay set to '\(client.uploadDelay)'s", color: .orange)
        UserDefaults.standard.set(client.uploadDelay, forKey: "client.uploadDelay")
    }
    
    private func setDownDelay(_ delta: Delta<TimeInterval>) {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }

        client.downloadDelay = delta.map{ TimeInterval($0) }.reduce(client.downloadDelay).clamped(0...)
        debugModel.sendLog(type: "Socket Config", message: "Download delay set to '\(client.downloadDelay)'s", color: .orange)
        UserDefaults.standard.set(client.downloadDelay, forKey: "client.downloadDelay")
    }
}

final private class AxDebugWSConfigCell: ACGridView {
    private let updelayLabel = ACAreaLabel_(title: "Up Delay:", alignment: .right, displayType: .valueName)
    let updelayField = ACNumberField_() => {
        $0.unit = "s"
        $0.arrowKeyStepValue = 0.01
    }
    
    private let downdelayLabel = ACAreaLabel_(title: "Down Delay:", alignment: .right, displayType: .valueName)
    let downdelayField = ACNumberField_() => {
        $0.unit = "s"
        $0.arrowKeyStepValue = 0.01
    }
    
    override func onAwake() {
        self.updelayField.fieldValue = .identical(0.01)
        self.downdelayField.fieldValue = .identical(0.01)
        
        self.addItem3(updelayLabel, row: 0, column: 0)
        self.addItem3(updelayField, row: 0, column: 1)
        
        self.addItem3(downdelayLabel, row: 1, column: 0)
        self.addItem3(downdelayField, row: 1, column: 1)
    }
}

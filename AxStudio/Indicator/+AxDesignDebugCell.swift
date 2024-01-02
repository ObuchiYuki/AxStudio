//
//  +AxDebugCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents
import AxCommand
import SwiftEx
import AppKit
import DesignKit
import BluePrintKit
import STDComponents
import LapixUI
import AxModelCore
//import SwiftUIExporter
//import iOSSimulatorKit

final class AxDesignDebugCellController: NSViewController {
    private let cell = AxDebugCell()
    private lazy var windowController = AxDebugWindowController.instantiate(document: self.document)
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
//        let nodeupdate = document.$selectedStatement.compactMap{ $0 }.map{ $0.$nodes }
//        document.$selectedStatement.compactMap{ $0 }.touch(nodeupdate).map{ IRActionNameGenerator.make(from: $0) }
//            .sink{[unowned self] in self.cell.layerIDLabel.stringValue = $0 }.store(in: &objectBag)
        
        cell.debugWindowButton.actionPublisher
            .sink{[unowned self] in self.windowController.showWindow(nil) }.store(in: &objectBag)
        
        cell.sessionIDField.stringValue = document.session.sessionID
        
        cell.restoreButton.actionPublisher
            .sink{[unowned self] in document.execute(AxRestoreModelCommand()) }.store(in: &objectBag)
        cell.breakButton.actionPublisher
            .sink{[unowned self] in self.raiseBreakpoint() }.store(in: &objectBag)
        
        cell.codeScreenButton.actionPublisher
            .sink{[unowned self] in self.emitScreenCode() }.store(in: &objectBag)
        cell.codeComponentButton.actionPublisher
            .sink{[unowned self] in self.emitComponentCode() }.store(in: &objectBag)
        cell.simulatorButton.actionPublisher
            .sink{[unowned self] in self.openSimulator() }.store(in: &objectBag)
        
        if DebugSettings.showDebugWindowOnLaunch {
            DispatchQueue.main.async { self.showDebugWindow() }
        }
    }
    
    private func openSimulator() {
//        NSWorkspace.shared.open(document.tmpExportDirectory)
    }
    
    private func emitComponentCode() {
//        guard let master = document.selectedLayers.firstSome(where: { $0 as? DKMasterLayer }) else { return }
//        
//        let block = try! __IEDebugComponentBlockEmitter.emit(master)
//        
//        print(block.componentClass)
    }
    
    private func emitScreenCode() {
        
    }
    
    private func raiseBreakpoint() {
        let layer = document.selectedLayers.first
        let parent = layer?.parent?.value
        CoreUtil.breakpoint()
        print(layer as Any, parent as Any)
    }
    
    private func showDebugWindow() {
        windowController.showWindow(nil)
    }
}

final private class AxDebugCell: ACGridView {
    let sessionIDLabel = ACAreaLabel_(title: "SessionID:", alignment: .right, displayType: .valueName)
    let sessionIDField = ACAreaLabel_(title: "0", displayType: .codeValue)
    
    let layerIDTitle = ACAreaLabel_(title: "Action:", alignment: .right, displayType: .valueName)
    let layerIDLabel = ACAreaLabel_(title: "--", displayType: .codeValue)
    
    let debugWindowButton = ACTitleButton_(title: "Show Debug Window")
    let restoreButton = ACTitleButton_(title: "Restore")
    let breakButton = ACTitleButton_(title: "Break")
    let codeScreenButton = ACTitleButton_(title: "Code(s)")
    let codeComponentButton = ACTitleButton_(title: "Code(c)")
    let simulatorButton = ACTitleButton__(title: "Tmp")
    
    override func onAwake() {
        self.addItem3(sessionIDLabel, row: 0, column: 0)
        self.addItem3(sessionIDField, row: 0, column: 1, length: 2)
        
        self.addItem3(layerIDTitle, row: 1, column: 0)
        self.addItem3(layerIDLabel, row: 1, column: 1, length: 2)
        
        self.addItem3(debugWindowButton, row: 2, column: 0, length: 3)
        
        self.addItem3(restoreButton, row: 3, column: 0)
        self.addItem3(breakButton, row: 3, column: 1)
        self.addItem3(codeScreenButton, row: 3, column: 2)
        self.addItem3(codeComponentButton, row: 4, column: 0)
        self.addItem3(simulatorButton, row: 4, column: 1)
    }
}

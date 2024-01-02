//
//  AxAppWindowController.swift
//  AxStudio
//
//  Created by yuki on 2021/09/10.
//

import BluePrintKit
import AppKit
import Combine
import SwiftEx
import DesignKit
import AxComponents
import AxModelCore
import AxDocument
import AxCommand
import Lapix
import Carbon.HIToolbox
import LayoutEngine

final class AxAppWindowController: NSWindowController {
        
    private var axDocument: AxDocument { chainObject as! AxDocument }

    @IBOutlet weak var zoomItem: ACToolbarZoomItem!
    
    @IBAction func home(_ sender: NSToolbarItem) { AxHomeWindowController.showAllInstantiatedControllers() }
    @IBAction func rectangle(_ menu: Any) { axDocument.execute(AxSetAddShapeCommand(shapeType: .rectangle)) }
    @IBAction func oval(_ menu: Any) { axDocument.execute(AxSetAddShapeCommand(shapeType: .ellipse)) }
    @IBAction func screen(_ menu: Any) { axDocument.execute(AxMakeScreenCommand()) }
    @IBAction func text(_ menu: Any) { axDocument.execute(AxSetAddShapeCommand(shapeType: .text)) }
    @IBAction func group(_ menu: Any) { axDocument.execute(AxMakeStackCommand()) }
    @IBAction func export(_ sender: Any) { exportViewModel.exportProject() }
    @IBAction func component(_ sender: Any) { AxComponentMaker.makeComponent(self.window!) }
    @IBAction func preview(_ sender: ACToolbarButton) { previewViewModel.previewProject(sender) }
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey.key {
        case .upArrow: axDocument.execute(AxArrowCommand(key: .up, shift: event.modifierFlags.contains(.shift), phase: .pulse(())))
        case .downArrow: axDocument.execute(AxArrowCommand(key: .down, shift: event.modifierFlags.contains(.shift), phase: .pulse(())))
        case .rightArrow: axDocument.execute(AxArrowCommand(key: .right, shift: event.modifierFlags.contains(.shift), phase: .pulse(())))
        case .leftArrow: axDocument.execute(AxArrowCommand(key: .left, shift: event.modifierFlags.contains(.shift), phase: .pulse(())))
        default:
            super.keyDown(with: event)
        }
    }
    
    private var isPreviewExporting = false
    
    private lazy var zoomViewModel = AxAppWindowZoomViewModel(zoomItem)
    private lazy var debugViewModel = AxAppDebugViewModel()
    private lazy var exportViewModel = AxExportViewModel(window!)
    private lazy var previewViewModel = AxPreviewViewModel(window!)
    
    private lazy var appMenuResponder = AxAppMenuResponder(axDocument)
            
    override func chainObjectDidLoad() {
        NotificationCenter.default.post(name: AxDocument.chainObjectDidLoadNotification, object: self.window)
        
        self.window?.setFrameAutosaveName("\(axDocument.rootNode.id)")
        
        self.axDocument.errorPublisher
            .sink{ ACToast(message: $0.title, action: $0.action, color: .systemRed).show(with: TimeInterval($0.duration ?? 2)) }.store(in: &objectBag)
        
        self.axDocument.warningPublisher
            .sink{ ACToast(message: $0.title, action: $0.action, color: .systemYellow).show(with: TimeInterval($0.duration ?? 2)) }.store(in: &objectBag)
        
        self.axDocument.noticePublisher
            .sink{ ACToast(message: $0.title, action: $0.action).show(with: TimeInterval($0.duration ?? 2)) }.store(in: &objectBag)
        
        self.axDocument.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink{ self.showProgress($0) }.store(in: &objectBag)
        
        self.axDocument.session.undoManager.undoManager = self.window?.undoManager
        
        self.zoomViewModel.loadDocument(axDocument)
        self.previewViewModel.loadDocument(axDocument)
        #if DEBUG
        self.debugViewModel.loadDocument(axDocument)
        #endif
        
        self.setupRestoreChecker()
        self.nextResponder = appMenuResponder
    }
    
    private func showProgress(_ progress: AxDocument.TaskProgress) {
        let toast = ACToast(message: progress.title)
        if let cancelHandler = progress.cancelHandler {
            toast.action = Action(title: "Cancel", action: cancelHandler)
        }
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.startAnimation(nil)
        indicator.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        toast.addAttributeView(indicator, position: .left)
        toast.show(with: { handler in
            progress.endHandler{ DispatchQueue.main.async(execute: handler) }
        })
    }

    override func windowDidLoad() {
        self.window?.backgroundColor = AxComponents.R.Color.windowToolbar
        self.window?.minSize = [670, 490]
        self.window?.setContentSize([1172, 781])
    }
    
    private func setupRestoreChecker() {
        Timer.scheduledTimer(withTimeInterval: 480, repeats: true) {[weak axDocument] timer in
            guard let axDocument = axDocument else { return timer.invalidate() }
            axDocument.execute(AxRestoreModelCommand())
        }
        axDocument.execute(AxRestoreModelCommand())
    }
}

extension AxAppWindowController {
    static let storyboard = NSStoryboard(name: "AppMain", bundle: .main)
    
    static func instantiate() -> AxAppWindowController {
        let windowController = storyboard.instantiateController(withIdentifier: R.SceneIdentifier.appWindowController) as! AxAppWindowController
        return windowController
    }
}

extension AxAppWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) { axDocument.close() }
}



final class AxAppWindow: NSWindow {}

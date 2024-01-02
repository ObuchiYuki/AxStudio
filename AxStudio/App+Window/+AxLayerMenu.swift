//
//  +AxLayerMenu.swift
//  AxCommand
//
//  Created by yuki on 2020/10/26.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxDocument
import DesignKit
import AxCommand
import AxComponents

final public class AxLayerMenuGenerator {
    let document: AxDocument
    let view: NSView
    
    public enum Context {
        case canvas
        case layerList
    }
    
    public init(document: AxDocument, view: NSView) {
        self.document = document
        self.view = view
    }
    
    public func make(for context: Context) -> NSMenu {
        let menu = NSMenu()
        
        if document.selectedLayers.isEmpty {
            self.addEmptyItems(to: menu)
        } else {
            self.addNormalLayersItems(to: menu)
            
            if document.selectedLayers.count > 1 {
                let canMakeGroup = !document.selectedLayers.contains(where: { $0.isRootOnly })
                if canMakeGroup {
                    menu.addItem(.separator())
                    self.addGroupItem(to: menu)
                }
            }
            menu.addItem(.separator())
            if document.selectedLayers.allSatisfy({ !$0.isRootOnly }) {
                menu.addItem("Create Component") {
                    if let window = self.view.window { AxComponentMaker.makeComponent(window) }
                }
            }
            
            if document.selectedLayers.count == 1 {
                if let master = document.selectedLayers.first as? DKMasterLayer {
                    menu.addItem("Create Instance") { self.makeInstance(master) }
                    menu.addItem("Create List") { self.document.execute(AxMakeListCommand(master)) }
                }
                if let instance = document.selectedLayers.first as? DKInstanceLayer, let master = instance.master.get(document.session) {
                    menu.addItem("Edit Master") { self.document.execute(AxEditMasterCommand(master)) }
                }
            }
        }
        
        if context == .canvas {
            menu.addItem(.separator())
            self.addZoomItems(to: menu)
            if document.selectedLayers.count == 1 {
                menu.addItem("Fit to Layer") {
                    self.document.execute(AxFitLayersCommand())
                }
            } else if document.selectedLayers.count > 1 {
                menu.addItem("Fit to Layers") {
                    self.document.execute(AxFitLayersCommand())
                }
            }
        }

        return menu
    }
    
    private func makeInstance(_ master: DKMasterLayer) {
        document.execute(AxMakeInstanceCommand(master, location: nil))
    }
    
    private func addGroupItem(to menu: NSMenu) {
        menu.addItem("Group Selection") {
            self.document.execute(AxMakeGroupCommand())
        }
        menu.addItem("Stack Selection") {
            self.document.execute(AxMakeStackCommand())
        }
    }
    
    private func addZoomItems(to menu: NSMenu) {
        menu.addItem("Fit to Page") {
            self.document.execute(AxFitPageCommand())
        }
        menu.addItem("Fit to Screen") {
            self.document.execute(AxFitScreenCommand())
        }
    }
    
    private func addEmptyItems(to menu: NSMenu) {
        if AxCanvasPasteCommand.canPaste(with: .general) {
            menu.addItem("Paste") {
                self.document.execute(AxCanvasPasteCommand())
            }
        }
    }
    
    private func addNormalLayersItems(to menu: NSMenu) {
        menu.addItem("Cut") {
            self.document.execute(AxCutLayerCommand())
        }
        menu.addItem("Copy") {
            self.document.execute(AxCopyLayerCommand())
        }
        if AxCanvasPasteCommand.canPaste(with: .general) {
            menu.addItem("Paste") {
                self.document.execute(AxCanvasPasteCommand())
            }
        }
        menu.addItem("Duplicate") {
            self.document.execute(AxDuplicateLayerCommand())
        }
        menu.addItem(.separator())
        menu.addItem("Delete") {
            self.document.execute(AxRemoveLayersCommand())
        }
    }
}

import SwiftEx
import AppKit

enum AxComponentMaker {
    static func makeComponent(_ window: NSWindow) {
        guard let document = window.document else { return __warn_ifDebug_beep_otherwise() }
        guard document.selectedLayers.allSatisfy({ $0.canBecomeComponent }) else { return NSSound.beep() }
        
        let alert = NSAlert()
        let textField = ACTextField_(frame: NSRect(size: [225, 21]))
        textField.snp.makeConstraints{ make in
            make.width.equalTo(225)
        }
        textField.placeholder = "Component name"
        
        let okButton = alert.addButton(withTitle: "OK")
        alert.accessoryView = textField
        alert.messageText = "Create new Component"
        alert.informativeText = "The Selected layers will be replaced by a single layer. A new Component will be created in your document. Whenever this Component is edited, all its layers will update to refrect the changes."
        alert.addButton(withTitle: "Cancel")
        okButton.isEnabled = false
        var string = ""
        textField.changePublisher
            .sink{
                string = $0
                okButton.isEnabled = !$0.isEmpty
            }
            .store(in: &textField.objectBag)
        alert.beginSheetModal(for: window) { res in
            if res == .alertFirstButtonReturn {
                document.execute(AxMakeComponentCommand(document.selectedLayers, name: string))
            }
        }
        DispatchQueue.main.async{
            textField.window?.makeFirstResponder(textField.textField)
        }
    }
}

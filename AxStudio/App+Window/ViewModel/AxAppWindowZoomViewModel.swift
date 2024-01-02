//
//  AxAppWindowZoomViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/11/11.
//

import BluePrintKit
import AxComponents
import SwiftEx
import AppKit
import AxDocument
import AppKit
import DesignKit
import AxCommand

private let zoomCases: [CGFloat] = [0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 1, 2, 4]

final class AxAppWindowZoomViewModel {
    private let zoomItem: ACToolbarZoomItem
        
    private let zoom50Item = NSMenuItem(title: "50 %")
    private let zoom100Item = NSMenuItem(title: "100 %")
    private let zoom200Item = NSMenuItem(title: "200 %")
    
    private let fitPageItem = NSMenuItem(title: "Fit Page")
    private let fitScreenItem = NSMenuItem(title: "Fit Screen")
    private let fitLayersItem = NSMenuItem(title: "Fit Layers")
    
    private let fitBluePrintItem = NSMenuItem(title: "Fit BluePrint")
    private let fitNodesItem = NSMenuItem(title: "Fit Nodes")
    
    private var designBag = Set<AnyCancellable>()
    private var bluePrintBag = Set<AnyCancellable>()
    
    init(_ zoomItem: ACToolbarZoomItem) { self.zoomItem = zoomItem }
    
    func loadDocument(_ document: AxDocument) {
        document.currentNodeContainerp
            .sink{[unowned document] container in
                if let container = container { self.setBluePrintItems(document, container: container) } else { self.setDesignItems(document) }
            }
            .store(in: &document.objectBag)
    }
    
    private func nextZoom(_ scroll: Scroll) -> CGFloat {
        zoomCases.first(where: { $0 > scroll.magnification }) ?? zoomCases.last!
    }
    private func prevZoom(_ scroll: Scroll) -> CGFloat {
        zoomCases.reversed().first(where: { $0 < scroll.magnification }) ?? zoomCases.first!
    }
    
    private func setDesignItems(_ document: AxDocument) {
        self.zoom50Item.setAction {[unowned document] in document.execute(AxCanvasZoomCommand(.to(0.5), animates: true)) }
        self.zoom100Item.setAction {[unowned document] in document.execute(AxCanvasZoomCommand(.to(1.0), animates: true)) }
        self.zoom200Item.setAction {[unowned document] in document.execute(AxCanvasZoomCommand(.to(2.0), animates: true)) }
        
        self.fitPageItem.setAction {[unowned document] in document.execute(AxFitPageCommand()) }
        self.fitScreenItem.setAction {[unowned document] in document.execute(AxFitScreenCommand()) }
        self.fitLayersItem.setAction {[unowned document] in document.execute(AxFitLayersCommand()) }
        
        self.designBag.removeAll()
        
        self.zoomItem.plusButton.actionPublisher
            .sink{[unowned document] in document.execute(AxCanvasZoomCommand(.to(self.nextZoom(document.canvasScroll)), animates: true)) }.store(in: &designBag)
        self.zoomItem.minusButton.actionPublisher
            .sink{[unowned document] in document.execute(AxCanvasZoomCommand(.to(self.prevZoom(document.canvasScroll)), animates: true)) }.store(in: &designBag)
        
        document.rootNode.appPage.$layers.map{ !$0.isEmpty }
            .sink{[unowned self] in fitPageItem.isEnabled = $0 }.store(in: &designBag)
        document.$selectedLayers.combineLatest(document.rootNode.appPage.$layers).map{ AxFitScreenCommand.targetLayer($0, $1) != nil }
            .sink{[unowned self] in fitScreenItem.isEnabled = $0 }.store(in: &designBag)
        document.$selectedLayers.map{ !$0.isEmpty }
            .sink{[unowned self] in fitLayersItem.isEnabled = $0 }.store(in: &designBag)
        
        document.$canvasScroll.map{ $0.magnification }.removeDuplicates()
            .sink{[unowned self] in zoomItem.magnification = $0 }.store(in: &designBag)
        
        self.zoomItem.replaceMenuItems([
            zoom50Item, zoom100Item, zoom200Item,
            .separator(),
            fitPageItem, fitScreenItem, fitLayersItem
        ])
    }
    private func setBluePrintItems(_ document: AxDocument, container: BPContainer) {
        self.zoom50Item.setAction { document.execute(AxZoomBluePrintCommand(.to(0.5), animates: true, container)) }
        self.zoom100Item.setAction { document.execute(AxZoomBluePrintCommand(.to(1.0), animates: true, container)) }
        self.zoom200Item.setAction { document.execute(AxZoomBluePrintCommand(.to(2.0), animates: true, container)) }
        
        self.fitNodesItem.setAction {document.execute(AxFitNodesCommand(container)) }
        self.fitBluePrintItem.setAction {document.execute(AxFitBluePrintCommand(container)) }
        
        self.bluePrintBag.removeAll()
        
        self.zoomItem.plusButton.actionPublisher
            .sink{[unowned document] in document.execute(AxZoomBluePrintCommand(.to(self.nextZoom(container.scroll)), animates: true, container)) }.store(in: &designBag)
        self.zoomItem.minusButton.actionPublisher
            .sink{[unowned document] in document.execute(AxZoomBluePrintCommand(.to(self.prevZoom(container.scroll)), animates: true, container)) }.store(in: &designBag)
        
        container.$nodes.map{ !$0.isEmpty }
            .sink{[unowned self] in fitBluePrintItem.isEnabled = $0 }.store(in: &designBag)
        container.$selectedNodes.map{ !$0.isEmpty }
            .sink{[unowned self] in fitNodesItem.isEnabled = $0 }.store(in: &designBag)
        
        container.$scroll.map{ $0.magnification }.removeDuplicates()
            .sink{[unowned self] in zoomItem.magnification = $0 }.store(in: &designBag)
        
        self.zoomItem.replaceMenuItems([
            zoom50Item, zoom100Item, zoom200Item,
            .separator(),
            fitBluePrintItem, fitNodesItem
        ])
    }
}

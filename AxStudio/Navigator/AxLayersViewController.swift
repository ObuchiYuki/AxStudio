//
//  +AxLayersView.swift
//  AxStudio
//
//  Created by yuki on 2020/09/22.
//  Copyright © 2020 yuki. All rights reserved.
//

import DesignKit
import AxComponents
import AxCommand
import AppKit

class AxLayersViewController: ACLayerViewController {
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        let menu = AxLayerMenuGenerator(document: document, view: self.view).make(for: .layerList)
        menu.popUp(positioning: nil, at: view.convert(event.locationInWindow, from: nil), in: view)
    }

    override func chainObjectDidLoad() {
        self.rootLayer = document.rootNode.appPage
        self.delegate = self
        document.$selectedLayers
            .sink {[unowned self] in self.selectedLayers = $0 }.store(in: &objectBag)
    }
    
    @IBAction func copy(_ sender: Any) {
        document?.execute(AxCopyLayerCommand())
    }
    @IBAction func paste(_ sender: Any) {
        document?.execute(AxCanvasPasteCommand())
    }
    @IBAction func cut(_ sender: Any) {
        document?.execute(AxCutLayerCommand())
    }
    @IBAction func duplicate(_ sender: Any) {
        document?.execute(AxDuplicateLayerCommand())
    }
    @IBAction func delete(_ sender: Any) {
        document?.execute(AxRemoveLayersCommand())
    }
}

extension AxLayersViewController: ACLayerViewDelegate {
    var autosaveName: String { "applicationLayerView" }

    func layerView(onSelectLayers layers: [DKLayer]) {
        document.execute(AxSelectLayerCommand(select: .to(layers)))
    }
    func layerView(didRenameLayer layer: DKLayer, to name: String) {
        document.execute(AxLayerNameCommand(layer: layer, name: name))
    }
    func layerView(didMoveLayers layers: [DKLayer], into layer: DKContainerLayer, at index: Int) {
        document.execute(AxMoveSublayerCommand(layers: layers, container: layer, outlineViewIndex: index))
    }
    func layerView(didToggleIsHiddenOfLayer layer: DKLayer) {
        document.execute(AxToggleHiddenCommand(layer: layer))
    }
}

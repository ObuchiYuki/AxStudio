//
//  +AxAssetComponentsView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/28.
//

import DesignKit
import SwiftEx
import AxComponents
import AxCommand
import AxDocument
import Combine
import AxModelCore

final class AxLocalAssetComponentsViewController: ACComponentViewController {
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete:
            guard let assets = self.selectedAssetItems as? [DKComponentAsset] else { return }
            self.removeComponent(assets)
        default: super.keyDown(with: event)
        }
    }

    override func buildMenu(at indexPaths: Set<IndexPath>, assetItems: [ACComponentAssetItem]) -> NSMenu? {
        guard let assets = assetItems as? [DKComponentAsset], !assets.isEmpty else { return nil }
        
        let menu = NSMenu()
        if assets.count == 1, let asset = assets.first {
            guard let master = asset.master.value else { return nil }
            menu.addItem("Remove Component") { self.removeComponent([asset]) }
            menu.addItem("Edit Master") { self.document.execute(AxEditMasterCommand(master)) }
        } else {
            menu.addItem("Remove Components") { self.removeComponent(assets) }
        }
        return menu
    }
    
    private func removeComponent(_ componentAssets: [DKComponentAsset]) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to delete this Component?";
        alert.informativeText = "You can undo this operation."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            self.document.execute(AxRemoveComponentAssetCommand(componentAssets))
        }
    }
    
    override func chainObjectDidLoad() {
        self.autosaveName = "asset.local.\(document.rootNode.id)"
        let rootGroup = document.rootNode.assetStore.componentRootGroup
        rootGroup.recursiveSubgroupp.map{ [rootGroup] + $0 }
            .sink{[unowned self] in self.componentGroups = $0 }.store(in: &objectBag)
    }
}


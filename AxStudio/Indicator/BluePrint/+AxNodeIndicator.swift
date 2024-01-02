//
//  AxNodeIndicatorView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/12.
//

import AppKit
import BluePrintKit
import EmeralyUI
import AxComponents
import AxCommand
import AxDocument
import SwiftEx
import DesignKit
import Neontetra

final class AxNodeIndicatorViewController: ACStackViewController_ {
    private let previewCell = AxNodePreviewCellController()
    private let inputsCell = AxNodeInputListController()
    
    private let transitionHeaderCell = ACStackViewFoldHeaderController(title: "Transition", autosaveName: "node.transition")
    private let transitionCell = AxTransitionNodeController()
    
    private let jsonHeaderCell = ACStackViewFoldHeaderController(title: "JSON", autosaveName: "node.json")
    private let jsonCell = AxJSONCellController()
    
    private let urlparamsHeaderCell = AxURLParamatorHeaderController(title: "URL Paramators", autosaveName: "node.url.params")
    private let urlparamsListCell = AxURLParamatorListCellController()
    
    private let headerHeaderCell = AxRequestHeadersHeaderController(title: "Request Headers", autosaveName: "node.req.head")
    private let headerListCell = AxRequestHeaderListCellController()
    
    private let sequenceHeaderCell = AxRequestHeadersHeaderController(title: "Sequence", autosaveName: "node.seq")
    private let sequenceCell = AxSequenceNodeCellController()
    
    private let switchHeaderCell = AxSwitchNodeHeaderController(title: "Switch", autosaveName: "node.switch")
    private let switchCell = AxSwitchNodeListCellController()
    
    private let genericCell = AxGenericNodeCellController()
    
    private let statesHeaderCell = ACStateHeaderController(title: "States")
    private let stateListCell = AxStateListCellController()
    private let stateInfoCell = AxStateInfoCellController()
    
    private lazy var nodeSelector = ACStackViewCellSelector_<[BPNode]>(self)
    private lazy var layerSelector = ACStackViewCellSelector_<[DKLayer]>(self)
    
    override func chainObjectDidLoad() {
        let parentChange = document.$selectedLayers.switchToLatest{ $0.map{ $0.$parent }.combineLatest }
        let states = document.$selectedLayers.map{ $0.singleOrNil()?.statesp }.involveSwitchToLatest()
        let reload = document.$selectedLayers.touch(parentChange, document.$selectedState).touch(states)
            .grouping(by: document.executeSession)
        reload
            .sink{[unowned self] in self.layerSelector.reloadData(with: $0) }.store(in: &objectBag)
        reload.grouping(by: document.selectionSession)
            .sink{[unowned self] _ in self.view.window?.recalculateKeyViewLoop() }.store(in: &objectBag)
        
        let nodes = document.currentNodeContainerp.compactMap{ $0 }.switchToLatest{ $0.$selectedNodes }
        nodes.sink{[unowned self] in self.nodeSelector.reloadData(with: $0) }.store(in: &objectBag)
        nodes.grouping(by: document.selectionSession)
            .sink{[unowned self] _ in self.view.window?.recalculateKeyViewLoop() }.store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.addCell(previewCell, spaceAfter: 0)
        self.addCell(.separator())
        self.addCell(inputsCell)
        
        self.nodeSelector.register(genericCell) { nodes in
            nodes.singleOrNil() is BPGenericsNodeType
        }
        
        self.nodeSelector.registerFoldable(transitionHeaderCell, [transitionCell]) { nodes in
            nodes.singleOrNil() is BPTransitionNode
        }
        self.nodeSelector.registerFoldable(sequenceHeaderCell, [sequenceCell]) { nodes in
            nodes.singleOrNil() is BPSequenceNode
        }
        self.nodeSelector.registerFoldable(jsonHeaderCell, [jsonCell]) { nodes in
            nodes.singleOrNil() is BPJSONPathNode
        }
        self.nodeSelector.registerFoldable(urlparamsHeaderCell, [urlparamsListCell]) { nodes in
            nodes.singleOrNil() is BPURLBuilderNodeType
        }
        self.nodeSelector.registerFoldable(headerHeaderCell, [headerListCell]) { nodes in
            nodes.singleOrNil() is BPAdvancedNetworkNode
        }
        self.nodeSelector.registerFoldable(switchHeaderCell, [switchCell]) { nodes in
            nodes.singleOrNil() is BPSwitchNode
        }
                
        self.layerSelector.registerFoldable(statesHeaderCell, [
            .group([stateListCell]) { layers in !(layers.first?.states?.isEmpty ?? true) },
            .group([.separator(padding: .inset), stateInfoCell]) { _ in self.document.selectedState != nil },
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.viewModelLayer != nil || $0.componentLayer != nil })
        }
        
        self.layerSelector.reloadData(with: document.selectedLayers)
        self.nodeSelector.reloadData(with: [])

        DispatchQueue.main.async {
            self.view.window?.recalculateKeyViewLoop()
        }
    }
}




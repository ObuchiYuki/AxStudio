//
//  +AxViewModelIndicator.swift
//  AxStudio
//
//  Created by yuki on 2021/12/12.
//

import AppKit
import DesignKit
import AxComponents
import BluePrintKit
import STDComponents
import SwiftEx

final class AxViewModelIndicatorViewController: ACStackViewController_ {
    
    private let componentActionHeaderCell = ACComponentActionHeaderController(title: "Call for Action")
    private let componentActionListCell = AxComponentActionListCellController()
    
    private let statesHeaderCell = ACStateHeaderController(title: "States")
    private let stateListCell = AxStateListCellController()
    private let stateInfoCell = AxStateInfoCellController()
        
    private let actionHeaderCell = AxActionHeaderController(title: "Actions")
    private let actionListCell = AxActionListCellController()
    
    private lazy var selector = ACStackViewCellSelector_<[DKLayer]>(self)
    
    override func chainObjectDidLoad() {
        let parentChange = document.$selectedLayers.switchToLatest{ $0.map{ $0.$parent }.combineLatest }
        let states = document.$selectedLayers.map{ $0.singleOrNil()?.statesp }.involveSwitchToLatest()
        let actions = document.$selectedLayers.map{ $0.singleOrNil()?.viewModelLayer?.viewModel.$actions }.involveSwitchToLatest()
        let cactions = document.$selectedLayers.map{ $0.singleOrNil()?.componentLayer?.$componentActions }.involveSwitchToLatest()
        
        let reload = document.$selectedLayers.touch(parentChange, document.$selectedState, document.$selectedAction).touch(states, actions, cactions)
            .grouping(by: document.executeSession)
        
        reload
            .sink{[unowned self] in self.selector.reloadData(with: $0) }.store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.stackView.edgeInsets.top = -1
        self.stackView.edgeInsets.bottom = 8
        self.selector.registerFoldable(statesHeaderCell, [
            .group([stateListCell]) { layers in !(layers.first?.states?.isEmpty ?? true) },
            .group([.separator(padding: .inset), stateInfoCell]) { _ in self.document.selectedState != nil },
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.viewModelLayer != nil || $0.componentLayer != nil })
        }
        self.selector.registerFoldable(componentActionHeaderCell, [
            .group([componentActionListCell]) { layers in !(layers.first?.componentLayer?.componentActions.isEmpty ?? true) }
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.componentLayer != nil })
        }
        self.selector.registerFoldable(actionHeaderCell, [
            .group([actionListCell]) { layers in !(layers.first?.viewModelLayer?.viewModel.actions.isEmpty ?? true) }
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.viewModelLayer != nil })
        }
        
    }
}

final class AxViewModelIndicatorHeaderViewController: NSViewController {
    private let cell = AxViewModelIndicatorHeaderView()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        document.$selectedLayers
            .sink{[unowned self] in self.updateTitle(with: $0) }.store(in: &objectBag)
    }
    
    private func updateTitle(with layers: [DKLayer]) {
        if layers.isEmpty {
            self.view.isHidden = true
            self.cell.title = "Nothing Selected"
        } else if layers.count == 1 {
            if let viewModelLayer = layers.first?.viewModelLayer {
                self.view.isHidden = false
                if viewModelLayer is DKScreen {
                    cell.title = "Screen View Model"
                }
            } else if layers.first?.componentLayer != nil {
                self.view.isHidden = false
                cell.title = "Component"
            } else {
                self.view.isHidden = true
                cell.title = "Nothing Selected"
            }
        } else {
            self.view.isHidden = true
            cell.title = "Multiple Selected"
        }
    }
}

final private class AxViewModelIndicatorHeaderView: NSLoadView {
    var title: String { get { titleLabel.stringValue } set { titleLabel.stringValue = newValue } }
    
    private let titleLabel = NSTextField(labelWithString: "View Model")
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.textBackgroundColor.withAlphaComponent(0.3).cgColor
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.addSubview(titleLabel)
        self.snp.makeConstraints{ make in
            make.height.equalTo(24)
        }
        self.titleLabel.alignment = .left
        self.titleLabel.font = .systemFont(ofSize: AxComponents.R.FontSize.control)
        self.titleLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
}

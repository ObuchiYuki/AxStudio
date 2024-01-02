//
//  +AxInstanceCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/17.
//

import SwiftEx
import DesignKit
import Combine
import BluePrintKit
import AxComponents
import Neontetra
import AxCommand
import AxModelCore

final class AxInstanceCellController: NSViewController {
    private let menuController = AxInstanceMenuCellController()
    private let listController = AxInstanceListCellController()
    private let actionController = AxInstanceActionListCellController()
    private let separator = ACSeparatorView()
    private let stackView = NSStackView()
    
    override func loadView() { self.view = stackView }
    
    override func chainObjectDidLoad() {
        let instance = document.selectedUnmasteredLayersp.filter({ $0.count == 1 }).compactMap{ $0.first as? DKInstanceLayer }
        
        let actions = instance.switchToLatest{
            $0.$master.compactMap{ $0.value }.switchToLatest{ $0.$componentActions }
        }
        
        actions.sink{[unowned self] in separator.isHidden = $0.isEmpty }.store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.stackView.orientation = .vertical
        self.stackView.spacing = 8
        self.stackView.edgeInsets = .zero
        
        self.addChild(menuController)
        self.stackView.addArrangedSubview(menuController.view)
        
        self.addChild(listController)
        self.stackView.addArrangedSubview(listController.view)
        
        self.stackView.addArrangedSubview(separator)
        separator.padding = .init(left: 18, right: 0)
        
        self.addChild(actionController)
        self.stackView.addArrangedSubview(actionController.view)
    }
}

final private class AxInstanceMenuCellController: NSViewController {
    private let cell = AxInstanceMenuCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let instance = document.selectedUnmasteredLayersp.filter({ $0.count == 1 }).compactMap{ $0.first as? DKInstanceLayer }
        
        instance.switchToLatest{ $0.$master }.map{ $0.value?.asset?.value }
            .sink{[unowned self] in cell.componentWell.componentAsset = $0 }.store(in: &objectBag)
        
        cell.componentWell.assetPublisher
            .sink{[unowned self] in document.execute(AxReplaceMasterCommand($0)) }.store(in: &objectBag)
        cell.editMasterButton.actionPublisher
            .sink{[unowned self] in
                guard let instance = document.selectedLayers.first as? DKInstanceLayer, let master = instance.master.value else { return }
                document.execute(AxEditMasterCommand(master))
            }
            .store(in: &objectBag)
    }
}


final private class AxInstanceMenuCell: ACGridView {
    let editMasterButton = ACTitleButton_(title: "Edit Master", image: R.Image.editMini)
    let detachButton = ACTitleButton_(title: "Detach", image: R.Image.detachIcon)
    let componentWell = ACComponentWell()
    
    override func onAwake() {
        self.addItem3(componentWell, row: 0, column: 0, length: 3)
        
        self.addItem2(editMasterButton, row: 2, column: 0)
        self.addItem2(detachButton, row: 2, column: 1)
    }
}

final private class AxInstanceListCellController: NSViewController {
        
    private let stackView = NSStackView()
    override func loadView() {
        self.stackView.orientation = .vertical
        self.stackView.edgeInsets = .zero
        self.stackView.spacing = 8
        self.view = stackView
    }
    
    override func chainObjectDidLoad() {
        let instance = document.selectedUnmasteredLayersp.filter({ $0.count == 1 }).compactMap{ $0.first as? DKInstanceLayer }
        
        let states = instance.switchToLatest{
            $0.$master.compactMap{ $0.value }.switchToLatest{ $0.$componentStates }
        }
            
        states
            .sink{[unowned self] states in
                guard let instance = document.selectedUnmasteredLayers.first as? DKInstanceLayer else { return }
                
                self.stackView.isHidden = states.isEmpty
                self.stackView.subviews.forEach{ $0.removeFromSuperview() }
                
                for state in states {
                    guard let override = document.layoutContext.child(for: instance).override as? NEInstanceOverride else { continue }
                    let cell = self.cellView(for: state, instance: instance, override: override)
                    self.stackView.addArrangedSubview(cell)
                }
            }
            .store(in: &objectBag)
    }
        
    private func cellView(for state: BPComponentState, instance: DKInstanceLayer, override: NEInstanceOverride) -> NSView {
        let ostate = override.states.map{ $0[state.id] }
        
        let cell = AxStateOverrideCell()
        ostate.map{ $0 != nil }
            .sink{[unowned cell] in cell.checkBox.checkState = .identical($0); cell.titleLabel.alphaValue = $0 ? 1 : 0.4 }.store(in: &cell.objectBag)
        state.$name
            .sink{[unowned cell] in cell.titleLabel.stringValue = $0 }.store(in: &cell.objectBag)
        state.$type
            .sink{[unowned cell] in cell.valueWell.type = $0; cell.valueTip.type = $0 }.store(in: &cell.objectBag)
        ostate.singleDynamicProperty(\DKOverrideState.$value, document: document)
            .sink{[unowned cell] in cell.valueWell.setDynamicState($0); cell.valueTip.setDynamicState($0) }.store(in: &cell.objectBag)
        
        cell.checkBox.checkPublisher
            .sink{[unowned self] in document.execute(AxToggleOverrideStateCommand($0, state, instance)) }.store(in: &objectBag)
        cell.valueWell.valuePublisher.compactMap{ $0 }
            .sink{[unowned self] in document.execute(AxUpdateOverrideStateValueCommand($0, state, instance)) }.store(in: &objectBag)
        cell.valueWell.statePublisher
            .sink{[unowned self] in document.execute(AxDynamicOverrideStateCommand(.linkToState($0), state, instance)) }.store(in: &objectBag)
        cell.valueTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicOverrideStateCommand($0, state, instance)) }.store(in: &objectBag)
        
        return cell
    }
}

final private class AxStateOverrideCell: ACGridView {
    let checkBox = ACCheckBox_()
    let titleLabel = ACAreaLabel_(title: "State", displayType: .valueName)
    let valueWell = ACValueWell_(stateDrop: true)
    let valueTip = ACDynamicTip.autoconnect(.bool)
    
    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.addItem3(titleLabel, row: 0, column: 0)
        self.addItem3(valueWell, row: 0, column: 1, length: 2, decorator: valueTip)
        self.valueWell.canSelectNil = false
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(R.Size.checkBoxLeft)
        }
    }
}

final private class AxInstanceActionListCellController: NSViewController {
    
    
    private let stackView = NSStackView()
    
    override func loadView() {
        self.stackView.orientation = .vertical
        self.stackView.edgeInsets = .zero
        self.stackView.spacing = 8
        self.view = stackView
    }
    
    override func chainObjectDidLoad() {
        let instance = document.selectedUnmasteredLayersp.filter({ $0.count == 1 }).compactMap{ $0.first as? DKInstanceLayer }
        
        let actions = instance.switchToLatest{
            $0.$master.compactMap{ $0.value }.switchToLatest{ $0.$componentActions }
        }
            
        actions
            .sink{[unowned self] actions in
                guard let instance = document.selectedUnmasteredLayers.first as? DKInstanceLayer else { return }
                
                self.stackView.isHidden = actions.isEmpty
                self.stackView.subviews.forEach{ $0.removeFromSuperview() }
                let overrideActionsp = instance.overrideActionsp
                for action in actions {
                    let cell = self.cellView(for: action, instance: instance, override: overrideActionsp)
                    self.stackView.addArrangedSubview(cell)
                }
            }
            .store(in: &objectBag)
    }
        
    private func cellView(for action: BPComponentAction, instance: DKInstanceLayer, override: AnyPublisher<[AxModelObjectID: DKOverrideAction], Never>) -> NSView {
        let oaction = override.map{ $0[action.id] }
        
        let cell = AxActionOverrideCell()
        oaction.map{ $0 != nil }
            .sink{[unowned cell] in cell.checkBox.checkState = .identical($0); cell.titleLabel.alphaValue = $0 ? 1 : 0.5 }
            .store(in: &cell.objectBag)
        action.$name
            .sink{[unowned cell] in cell.titleLabel.stringValue = $0 }.store(in: &cell.objectBag)
        oaction.map{ $0?.$value }.involveSwitchToLatest()
            .sink{[unowned cell] in cell.editButton.setDynamicAction($0); cell.valueTip.setDynamicAction($0) }.store(in: &cell.objectBag)
        
        cell.checkBox.checkPublisher
            .sink{[unowned self] in document.execute(AxToggleOverrideActionCommand($0, action, instance)) }.store(in: &cell.objectBag)
        cell.editButton.actionPublisher
            .sink{[unowned self] in
                guard let action = oaction.takeValue()?.flatMap({ $0 })?.value else { return __warn_ifDebug_beep_otherwise() }
                document.execute(AxEditBluePrintCommand(action))
            }
            .store(in: &cell.objectBag)
        cell.valueTip.commandPublisher
            .sink{[unowned self] in
                guard let oaction = oaction.takeValue()?.flatMap({ $0 }) else { return __warn_ifDebug_beep_otherwise() }
                document.execute(AxDynamicActionPropertyCommand($0, oaction, \DKOverrideAction.value))
            }
            .store(in: &cell.objectBag)
        
        return cell
    }
}

final private class AxActionOverrideCell: ACGridView {
    let checkBox = ACCheckBox_()
    let titleLabel = ACAreaLabel_(title: "Action", displayType: .valueName)
    let editButton = ACDynamicActionWell()
    let valueTip = ACDynamicActionTip.autoconnect()
    
    override func onAwake() {
        self.edgeInsets.left = R.Size.checkBoxStackLeft
        
        self.addItem3(titleLabel, row: 0, column: 0)
        self.addItem3(editButton, row: 0, column: 1, length: 2, decorator: valueTip)
        
        self.addSubview(checkBox)
        self.checkBox.snp.makeConstraints{ make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(R.Size.checkBoxLeft)
        }
    }
}

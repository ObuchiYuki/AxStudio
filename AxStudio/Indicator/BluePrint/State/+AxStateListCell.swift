//
//  +AxStateListCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import Combine
import SwiftEx
import AppKit
import AxComponents
import DesignKit
import BluePrintKit
import AxCommand

final class AxStateListCellController: NSViewController {
    
    private let listView = NSTableView.list()
    private var states = [BPState]() {
        didSet { listView.reloadData(); self.reloadSelection() }
    }
    private var selectedState: BPState? {
        didSet { self.reloadSelection() }
    }
    private var updatingSelection = false
    
    private func reloadSelection() {
        self.updatingSelection = true; defer { self.updatingSelection = false }
        
        if let index = states.firstIndex(where: { $0 === selectedState }) {
            listView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            listView.deselectAll(self)
        }
    }
    
    override func loadView() {
        self.listView.dataSource = self
        self.listView.delegate = self
        self.listView.allowsEmptySelection = true
        self.listView.allowsMultipleSelection = false
        self.listView.registerForDraggedType(.bpState)
        self.listView.draggingDestinationFeedbackStyle = .gap
        self.view = listView
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete: document.execute(AxRemoveStateCommand())
        default: super.keyDown(with: event)
        }
    }
    
    override func chainObjectDidLoad() {
        document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first?.statesp }.switchToLatest()
            .sink{[unowned self] in self.states = $0 }.store(in: &objectBag)
        document.$selectedState
            .sink{[unowned self] in self.selectedState = $0 }.store(in: &objectBag)
            
    }
}

extension AxStateListCellController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { states.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 28 }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let state = self.states.at(row) else { return nil }
        return state.pasteboardRefWriting(for: .bpState)
    }
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow: Int, proposedDropOperation operation: NSTableView.DropOperation) -> NSDragOperation {
        if operation != .on, info.draggingPasteboard.canReadType(.bpState) { return .generic }
        return .none
    }
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation operation: NSTableView.DropOperation) -> Bool {
        guard operation != .on, let state = info.draggingPasteboard.getNodeRefs(for: .bpState, session: document.session)?.first else { return false }
        document.execute(AxMoveStateCommand(state: state, index: row))
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let state = self.states.at(row) else { return nil }
        
        let cell = AxStateCell()
        state.$name.sink{[unowned cell] in cell.nameLabel.stringValue = $0 }.store(in: &cell.objectBag)
        state.$type.sink{[unowned cell] in cell.typeTip.type = $0 }.store(in: &cell.objectBag)
        
        cell.nameLabel.endEditingStringPublisher
            .sink{ self.document.execute(AxRenameStateCommand($0)) }.store(in: &cell.objectBag)
        
        return cell
    }
}

extension AxStateListCellController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard !self.updatingSelection else { return }
        guard let state = self.states.at(listView.selectedRow) else { return __warn_ifDebug_beep_otherwise() }
        document.execute(AxSelectStateCommand(state))
    }
}

final private class AxStateCell: NSLoadView {
    let typeTip = ACTypeTip()
    let nameLabel = NSTextField()
    
    override func onAwake() {
        self.addSubview(typeTip)
        self.typeTip.snp.makeConstraints{ make in
            make.size.equalTo(12)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(18)
        }
        
        self.addSubview(nameLabel)
        self.nameLabel.isBezeled = false
        self.nameLabel.isBordered = false
        self.nameLabel.drawsBackground = false
        self.nameLabel.font = .systemFont(ofSize: AxComponents.R.FontSize.control)
        self.nameLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(18)
            make.left.equalTo(self.typeTip.snp.right).offset(12)
        }
    }
}

extension DKLayer {
    var states: [BPState]? {
        if let master = self.componentLayer { return master.componentStates }
        if let vmlayer = self.viewModelLayer { return vmlayer.viewModel.states }
        return nil
    }
    var statesp: AnyPublisher<[BPState], Never>? {
        if let master = self.componentLayer {
            return master.$componentStates.map{ $0 }.eraseToAnyPublisher()
        }
        if let vmlayer = self.viewModelLayer {
            return vmlayer.viewModel.$states.eraseToAnyPublisher()
        }
        return nil
    }
}

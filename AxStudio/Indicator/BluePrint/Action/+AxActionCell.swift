//
//  +AcActionListCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/09.
//

import SwiftEx
import AppKit
import AxComponents
import BluePrintKit
import AxCommand

final class AxActionListCellController: NSViewController {
    private let listView = NSTableView.list()
    
    private var actions = [BPAction]() {
        didSet { self.listView.reloadData(); self.reloadSelection() }
    }
    private var selectedAction: BPAction? {
        didSet { self.reloadSelection() }
    }
    private var updatingSelection = false
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete: document.execute(AxRemoveActionCommand())
        default: super.keyDown(with: event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let row = listView.row(at: event.location(in: listView))
        guard let cell = listView.view(atColumn: 0, row: row, makeIfNecessary: false) as? ACActionCell else { return }
        
        let menu = NSMenu()
        
        menu.addItem("Rename") {[self] in
            view.window?.makeFirstResponder(cell.nameLabel)
        }
        menu.addItem("Remove") {[self] in
            execute(AxRemoveActionCommand())
        }
        menu.addItem("Edit Action") {[self] in
            self.document.selectedStatement = document.selectedAction
        }
        
        listView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        menu.popUp(positioning: nil, at: event.location(in: listView), in: listView)
    }
    
    override func loadView() {
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.draggingDestinationFeedbackStyle = .gap
        self.listView.registerForDraggedType(.bpAction)
        self.view = listView
    }
    
    override func chainObjectDidLoad() {
        let actions = document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first?.viewModelLayer }.switchToLatest{ $0.viewModel.$actions }
            
        actions
            .sink{[unowned self] in self.actions = $0 }.store(in: &objectBag)
        document.$selectedAction
            .sink{[unowned self] in self.selectedAction = $0 }.store(in: &objectBag)
        
    }
    
    private func reloadSelection() {
        self.updatingSelection = true; defer { self.updatingSelection = false }
        
        if let index = actions.firstIndex(where: { $0 === selectedAction }) {
            listView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            listView.deselectAll(self)
        }
    }
}

extension AxActionListCellController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { actions.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 28 }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let action = self.actions[row]
        let cell = ACActionCell()
        
        action.$name
            .sink{[unowned cell] in cell.nameLabel.stringValue = $0 }.store(in: &cell.objectBag)
        cell.nameLabel.endEditingStringPublisher
            .sink{[unowned self] in document.execute(AxRenameActionCommand($0)) }.store(in: &objectBag)
        cell.well.actionPublisher
            .sink{[unowned self] in self.document.selectedStatement = action }.store(in: &objectBag)
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard dropOperation != .on, let action = info.draggingPasteboard.getNodeRefs(for: .bpAction, session: document.session)?.first else { return false }
        document.execute(AxMoveActionCommand(action, row))
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow: Int, proposedDropOperation operation: NSTableView.DropOperation) -> NSDragOperation {
        if operation != .on, info.draggingPasteboard.canReadType(.bpComponentAction) { return .generic }
        return .none
    }
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let action = actions.at(row) else { return nil }
        return action.pasteboardRefWriting(for: .bpAction)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard !updatingSelection else { return }
        guard let action = actions.at(listView.selectedRow) else { return __warn_ifDebug_beep_otherwise("No row \(listView.selectedRow)") }
        
        document.execute(AxSelectActionCommand(action))
    }
}

final class ACActionCell: NSLoadView {
    let typeTip = ACTypeTip()
    let nameLabel = NSPassthroughTextField()
    let well = ACDynamicActionWell()
    
    override func onAwake() {
        self.addSubview(typeTip)
        self.typeTip.solidColor = .white
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
            make.right.equalToSuperview().inset(100)
            make.left.equalTo(self.typeTip.snp.right).offset(12)
        }
        
        self.addSubview(well)
        self.well.title = " Edit"
        self.well.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
            make.width.equalTo(74)
        }
    }
}

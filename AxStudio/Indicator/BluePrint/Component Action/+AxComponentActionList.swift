//
//  +AxActionListCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/09.
//

import SwiftEx
import AxComponents
import BluePrintKit
import AxCommand

final class AxComponentActionListCellController: NSViewController {
    private let listView = NSTableView.list()
    
    private var actions = [BPComponentAction]() {
        didSet { self.listView.reloadData(); self.reloadSelection() }
    }
    private var selectedAction: BPComponentAction? {
        didSet { self.reloadSelection() }
    }
    private var updatingSelection = false
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .delete: document.execute(AxRemoveComponentActionCommand())
        default: super.keyDown(with: event)
        }
    }
    
    override func loadView() {
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.draggingDestinationFeedbackStyle = .gap
        self.listView.registerForDraggedType(.bpComponentAction)
        self.view = listView
    }
    
    override func chainObjectDidLoad() {
        let actions = document.$selectedLayers.filter{ $0.count == 1 }.compactMap{ $0.first?.componentLayer }.switchToLatest{ $0.$componentActions }
            
        actions
            .sink{[unowned self] in self.actions = $0 }.store(in: &objectBag)
        document.$selectedComponentAction
            .sink{[unowned self] in self.selectedAction = $0 }.store(in: &objectBag)
        
    }
    
    private func reloadSelection() {
        self.updatingSelection = true
        
        if let index = actions.firstIndex(where: { $0 === selectedAction }) {
            listView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            listView.deselectAll(self)
        }
        
        
        self.updatingSelection = false
    }
}

extension AxComponentActionListCellController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { actions.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 28 }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let action = self.actions[row]
        let cell = ACComponentActionCell()
        
        action.$name
            .sink{[unowned cell] in cell.nameLabel.stringValue = $0 }.store(in: &cell.objectBag)
        cell.nameLabel.endEditingStringPublisher
            .sink{[unowned self] in document.execute(AxRenameComponentActionCommand($0)) }.store(in: &objectBag)
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard dropOperation != .on, let action = info.draggingPasteboard.nodeRefs(type: .bpComponentAction, session: document.session)?.first else { return false }
        document.execute(AxMoveComponentActionCommand(action, row))
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow: Int, proposedDropOperation operation: NSTableView.DropOperation) -> NSDragOperation {
        if operation != .on, info.draggingPasteboard.canReadType(.bpComponentAction) { return .generic }
        return .none
    }
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let action = actions.at(row) else { return nil }
        return action.pasteBoardRefStorage(forType: .bpComponentAction)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard !updatingSelection else { return }
        guard let action = actions.at(listView.selectedRow) else { return beepWarning("No row \(listView.selectedRow)") }
        
        document.execute(AxSelectComponentActionCommand(action))
    }
}

final private class ACComponentActionCell: NSLoadView {
    let typeTip = ACTypeTip()
    let nameLabel = NSTextField()
    
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
            make.right.equalToSuperview().inset(18)
            make.left.equalTo(self.typeTip.snp.right).offset(12)
        }
    }
}

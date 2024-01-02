//
//  +AxTableLinkCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/25.
//

import SwiftEx
import AxComponents
import BluePrintKit
import Combine
import STDComponents
import AxCommand
import DesignKit

final class AxTableLinkCellController: NSViewController {
    private let menuController = AxTableMenuCellController()
    private let listController = AxTableLinkListCellController()
    
    private let stackView = NSStackView()
    
    override func loadView() {
        self.stackView.orientation = .vertical
        self.view = stackView
    }
    
    override func viewDidLoad() {
        self.addChild(listController)
        self.stackView.addArrangedSubview(listController.view)
        
        self.addChild(menuController)
        self.stackView.addArrangedSubview(menuController.view)
    }
}

final private class AxTableMenuCellController: NSViewController {
    private let cell = AxTableMenuCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        cell.tableButton.actionPublisher
            .sink{[unowned self] in openTableWindow() }.store(in: &objectBag)
    }
    
    private func openTableWindow() {
        guard let list = document.selectedLayers.first as? STDList else { return }
        document.selectedTable = list.table
    }
}

final private class AxTableMenuCell: ACGridView {
    let tableButton = ACTitleButton_(title: "Edit Table", image: R.Image.editBluePrint)
    
    override func onAwake() {
        self.addItem3(tableButton, row: 0, column: 0, length: 3)
    }
}

final private class AxTableLinkListCellController: NSViewController {
    private let listView = NSTableView.list()
    
    private var cellModels = [AxTableLinkCellModel]() { didSet { self.listView.reloadData() } }
    
    override func loadView() {
        self.listView.dataSource = self
        self.listView.delegate = self
        self.listView.intercellSpacing = [0, 6]
        self.listView.selectionHighlightStyle = .none
        self.view = listView
    }
    
    override func chainObjectDidLoad() {
        let linkLayer = document.$selectedLayers.compactMap{ $0.first as? DKTableLinkLayer }
        let cellLayer = linkLayer.switchToLatest{ $0.cellLayerp.compactMap{ $0.value } }
        let states = cellLayer.switchToLatest{ $0.$componentStates }
        let links = linkLayer.switchToLatest{ $0.linkMap.linkMapp }
        
        let cellModels = states.map{ states -> [AxTableLinkCellModel] in
            guard let layer = self.document.selectedLayers.first as? DKTableLinkLayer else { return [] }
            
            return states.map{ state in
                AxTableLinkCellModel(state: state, table: layer.table, column: links.map{ $0[state.id] }.eraseToAnyPublisher())
            }
        }
        
        cellModels
            .sink{[unowned self] in self.cellModels = $0 }.store(in: &objectBag)
    }
}

extension AxTableLinkListCellController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { self.cellModels.count }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 20 }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellModel = self.cellModels.at(row) else { return nil }
        
        let cell = AxTableLinkCell()
        
        cell.columnWell.table = cellModel.table
        
        cellModel.state.$name
            .sink{[unowned cell] in cell.stateLabel.stringValue = $0 }.store(in: &cell.objectBag)
        cellModel.state.$type
            .sink{[unowned cell] in cell.columnWell.type = $0 }.store(in: &cell.objectBag)
        cellModel.column
            .sink{[unowned cell] in cell.columnWell.selectedColumn = $0 }.store(in: &cell.objectBag)
        cell.columnWell.columnPublisher
            .sink{[unowned self] in document.execute(AxUpdateTableLinkCommand(state: cellModel.state, column: $0)) }.store(in: &cell.objectBag)
        
        return cell
    }
}

final private class AxTableLinkCellModel {
    let table: BPTable
    let state: BPComponentState
    let column: AnyPublisher<BPTableColumn?, Never>
    
    init(state: BPComponentState,  table: BPTable, column: AnyPublisher<BPTableColumn?, Never>) {
        self.state = state
        self.column = column
        self.table = table
    }
}

final private class AxTableLinkCell: ACGridView {
    let stateLabel = ACAreaLabel_(title: "State", displayType: .valueName)
    let columnWell = ACColumnWell()
    
    override func onAwake() {
        self.addItem3(stateLabel, row: 0, column: 0)
        self.addItem3(columnWell, row: 0, column: 1, length: 2)
    }
}


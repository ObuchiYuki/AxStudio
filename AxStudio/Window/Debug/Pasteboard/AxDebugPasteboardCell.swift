//
//  AxDebugPasteboardCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/24.
//

import AxComponents
import SwiftEx
import AppKit
import Combine
import AppKit

final class AxDebugPasteboardViewController: ACStackViewController_ {
    
    let headerCell = ACStackViewHeaderCellController_(title: "Pasteboard", style: .ultraLarge)
    let reloadCell = AxDebugReloadCellController()
    let jsonCell = AxDebugPasteboardJSONViewController()
    
    override func chainObjectDidLoad() {
        self.reloadCell.reloadButton.actionPublisher
            .sink{[unowned self] in self.jsonCell.reload() }.store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.stackView.edgeInsets = .init(x: 8, y: 12)
        self.scrollView.drawsBackground = true
        
        self.stackView.snp.makeConstraints{ make in
            make.bottom.equalTo(scrollView.contentView).offset(-24)
        }
        
        self.addCell(headerCell)
        self.addCell(reloadCell)
        self.addCell(jsonCell)
    }
}

final class AxDebugReloadCellController: NSViewController {
    private let gridView = ACGridView()
    let reloadButton = ACTitleButton_(title: "Reload")
        
    override func loadView() { self.view = gridView }
    
    override func viewDidLoad() {
        self.gridView.addItem3(reloadButton, row: 0, column: 0)
    }
}

final class AxDebugPasteboardJSONViewController: NSViewController {
    private let scrollView = NSTextView.scrollableTextView()
    private var textView: NSTextView { scrollView.documentView as! NSTextView }
    
    func reload() {
        guard let plist = NSPasteboard.general.nodeObjects(type: .dkLayer) else {
            return textView.string = "<empty>"
        }
        
        guard let json = try? JSONSerialization.data(withJSONObject: plist, options: [.prettyPrinted]),
              let jsonString = String(data: json, encoding: .utf8)
        else { return textView.string = "<error>" }
            
        self.textView.string = jsonString
    }
    
    override func chainObjectDidLoad() {
        self.reload()
    }
    
    override func loadView() {
        self.textView.backgroundColor = NSColor.black.withAlphaComponent(0.03)
        self.textView.isEditable = false
        self.textView.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        self.view = scrollView
    }
}

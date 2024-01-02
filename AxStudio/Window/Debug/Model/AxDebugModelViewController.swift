//
//  AxDebugModelViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/18.
//

import AxComponents
import AppKit
import AxDocument

final class AxDebugModelViewController: ACStackViewController_ {
    
    let headerCell = ACStackViewHeaderCellController_(title: "Model", style: .ultraLarge)
    let infomationCell = AxDebugModelJSONViewController()
    
    override func viewDidLoad() {
        self.stackView.edgeInsets = .init(x: 8, y: 12)
        self.scrollView.drawsBackground = true
        
        self.stackView.snp.makeConstraints{ make in
            make.bottom.equalTo(scrollView.contentView).offset(-24)
        }
        
        self.addCell(headerCell)
        self.addCell(infomationCell)
    }
}

final class AxDebugModelJSONViewController: NSViewController {
    private let scrollView = NSTextView.scrollableTextView()
    private var textView: NSTextView { scrollView.documentView as! NSTextView }
    
    override func chainObjectDidLoad() {
        #warning("JSONは生成できない")
//        let jsonData = debugModel.document.rootNode.jsonData(options: [.prettyPrinted, .sortedKeys])
//        let json = String(data: jsonData, encoding: .utf8)
//        self.textView.string = json ?? "<error>"
    }
    
    override func loadView() {
        self.textView.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        self.view = scrollView
    }
}

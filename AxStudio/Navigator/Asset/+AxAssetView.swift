//
//  +AxAssetView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/28.
//

import AxComponents
import SwiftEx
import AppKit

final class AxAssetViewController: NSViewController {
    private let headerController = AxAssetHeaderViewController()
    private let separatorView = ACSeparatorView()
    private let contentController = AxAssetContentViewController()
    
    private let stackView = NSStackView()
    
    override func loadView() {
        self.stackView.orientation = .vertical
        self.stackView.spacing = 0
        self.stackView.edgeInsets = .init(x: 0, y: 0)
        self.view = stackView
    }
    
    override func viewDidLoad() {
        self.addChild(headerController)
        self.stackView.addArrangedSubview(headerController.view)
        
        self.stackView.addArrangedSubview(separatorView)
        self.separatorView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
        }
        
        self.addChild(contentController)
        self.stackView.addArrangedSubview(contentController.view)
    }
}


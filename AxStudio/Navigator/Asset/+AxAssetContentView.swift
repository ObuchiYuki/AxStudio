//
//  +AxAssetContentView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/28.
//

import AxComponents
import SwiftEx
import AppKit

final class AxAssetContentViewController: NSViewController {
    
    private lazy var standardController = AxStandardAssetViewController()
    private lazy var localController = AxLocalAssetViewController()
    
    private let contentView = NSPlaceholderView()
    
    private var contentVC: NSViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let contentVC = contentVC { self.addChild(contentVC); contentView.contentView = contentVC.view }
        }
    }
    
    override func loadView() { self.view = contentView }
    
    override func chainObjectDidLoad() {
        document.$assetLibraryType
            .sink{[unowned self] assetType in
                switch assetType {
                case .standard: self.contentVC = self.standardController
                case .thisDocument: self.contentVC = self.localController
                }
            }
            .store(in: &objectBag)
    }
}

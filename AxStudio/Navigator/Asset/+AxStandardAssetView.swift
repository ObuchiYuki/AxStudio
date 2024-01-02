//
//  +AxStandardAssetView.swift
//  AxStudio
//
//  Created by yuki on 2021/12/02.
//

import SwiftEx
import AppKit
import AxComponents
import AxDocument

final class AxStandardAssetViewController: NSViewController {
    private let cell = AxStandardAssetView()
    
    private var contentVC: NSViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let contentVC = contentVC { self.addChild(contentVC); self.cell.contentView.contentView = contentVC.view }
        }
    }
    
    private lazy var componentsController = AxStandardAssetComponentsViewController()
    private lazy var colorsController = AxStandardColorAssetViewController()
    private lazy var fontsController = AxStandardFontAssetViewController()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        self.cell.assetTypeTab.enumItemPublisher
            .sink{[unowned self] in document.assetTab = $0 }.store(in: &objectBag)
        
        self.document.$assetTab
            .sink{[unowned self] tab in
                switch tab {
                case .components: self.contentVC = componentsController
                case .colors: self.contentVC = colorsController
                case .fonts: self.contentVC = fontsController
                }
                cell.assetTypeTab.selectedEnumItem = tab
            }
            .store(in: &objectBag)
    }
}


final private class AxStandardAssetView: NSLoadView {
    let assetTypeTab = ACEnumTabBar<AxDocument.AssetTab>()
    let contentView = NSPlaceholderView()
    
    override func onAwake() {
        self.addSubview(contentView)
        self.addSubview(assetTypeTab)
        self.assetTypeTab.addItem(.components)
        self.assetTypeTab.addItem(.colors)
        self.assetTypeTab.addItem(.fonts)
        self.assetTypeTab.snp.makeConstraints{ make in
            make.top.right.left.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints{ make in
            make.top.equalTo(assetTypeTab.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        }
    }
}



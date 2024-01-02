//
//  +AxLocalAssetView.swift
//  AxStudio
//
//  Created by yuki on 2021/12/02.
//

import SwiftEx
import AppKit
import BluePrintKit
import AxComponents
import AxDocument

final class AxLocalAssetViewController: NSViewController {
    private let cell = AxLocalAssetView()
    
    private lazy var componentsController = AxLocalAssetComponentsViewController()
    private lazy var colorsController = AxLocalColorAssetViewController()
    private lazy var fontsController = AxLocalFontAssetViewController()
    
    private var contentVC: NSViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let contentVC = contentVC { self.addChild(contentVC); self.cell.contentView.contentView = contentVC.view }
        }
    }
    
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

extension AxDocument.AssetTab: ACTextItem {
    public static var allCases: [Self] = [.components, .colors, .fonts]
    
    public var title: String {
        switch self {
        case .components: return "Component"
        case .colors: return "Color"
        case .fonts: return "Text Style"
        }
    }
}

final private class AxLocalAssetView: NSLoadView {
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



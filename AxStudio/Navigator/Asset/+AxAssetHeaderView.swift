//
//  +AxAssetHeaderView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/28.
//

import AxComponents
import SwiftEx
import Combine
import AxDocument

final class AxAssetHeaderViewController: NSViewController {
    private let cell = AxAssetHeaderView()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        document.$assetLibraryType
            .sink{[unowned self] in cell.libraryTypePicker.selectedItem = $0 }.store(in: &objectBag)
        cell.libraryTypePicker.itemPublisher
            .sink{[unowned self] in document.assetLibraryType = $0 }.store(in: &objectBag)
    }
}

extension AxDocument.AssetLibraryType: ACTextItem {
    public static var allCases: [Self] = [.thisDocument, .standard]
    public var title: String {
        switch self {
        case .standard: return "Standard"
        case .thisDocument: return "This Document"
        }
    }
}

final private class AxAssetHeaderView: NSLoadView {
    let libraryTypePicker = ACEnumSelectionBar<AxDocument.AssetLibraryType>()
    
    override func onAwake() {
        self.addSubview(libraryTypePicker)
        self.libraryTypePicker.addItem(.thisDocument)
        self.libraryTypePicker.addItem(.standard)
        
        self.libraryTypePicker.snp.makeConstraints{ make in
            make.right.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }
    }
}


//
//  +AxFontAssetController.swift
//  AxStudio
//
//  Created by yuki on 2021/12/24.
//

import AxComponents
import AppKit
import SwiftEx
import DesignKit

final class AxLocalFontAssetViewController: ACFontAssetListViewController {
    override func chainObjectDidLoad() {
        document.rootNode.assetStore.$fontAssets
            .sink{[unowned self] in self.assetItems = $0 }.store(in: &objectBag)
    }
}

final class AxStandardFontAssetViewController: ACFontAssetListViewController {
    override func chainObjectDidLoad() {
        self.assetItems = ACStandardFontAssetGroup.shared.items
    }
}

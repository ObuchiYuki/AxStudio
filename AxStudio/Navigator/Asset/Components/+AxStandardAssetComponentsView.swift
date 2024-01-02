//
//  +AxAssetComponent.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import AxComponents
import SwiftEx
import AppKit
import DesignKit
import LapixUI
import AxCommand
import AxModelCore
import Combine

final class AxStandardAssetComponentsViewController: ACComponentViewController {
    override func chainObjectDidLoad() {
        self.componentGroups = [AxStandardAssetStore.makeStore(with: document)]
    }
}

extension AxStandardAssetStore: ACComponentGroup {
    var id: AxModelObjectID { .invalidID }
    var isRoot: Bool { true }
    var name: String { "Standard" }
    
    var assetItems: [ACComponentAssetItem] { self.layerAssets }
    var assetItemsp: AnyPublisher<[ACComponentAssetItem], Never> { .just(self.layerAssets) }
}

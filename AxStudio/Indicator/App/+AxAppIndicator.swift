//
//  AxApplicationIndicatorViewController.swift
//  AxStudio
//
//  Created by yuki on 2020/11/04.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import DesignKit
import AxDocument
import SwiftEx
import AxComponents

final class AxAppIndicatorViewController: ACStackViewController_ {

    private let deviceHeaderCell = ACStackViewFoldHeaderController(title: "Device")
    private let deviceCell = AxDeviceCellController()
    
    private let initialScreenHeaderCell = ACStackViewFoldHeaderController(title: "Initial Screen")
    private let initialScreenCell = AxInitialScreenCellController()
    
    private let debugHeaderCell = ACStackViewFoldHeaderController(title: "Debug", autosaveName: "debug.app")
    private let debugCell = AxAppDebugCellController()
    
    private lazy var selector = ACStackViewCellSelector_<Void>(self)

    override func viewDidLoad() {
        self.stackView.edgeInsets.top = -5
        
        self.selector.registerFoldable(deviceHeaderCell, [deviceCell]) { true }
        self.selector.registerFoldable(initialScreenHeaderCell, [initialScreenCell]) { true }
        
        #if DEBUG
        self.selector.registerFoldable(debugHeaderCell, [debugCell]) { true }
        #endif
        
        selector.reloadData(with: ())
    }
}

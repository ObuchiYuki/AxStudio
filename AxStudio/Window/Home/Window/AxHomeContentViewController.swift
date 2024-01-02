//
//  +AxHomeContentView.swift
//  AxComponents
//
//  Created by yuki on 2021/01/24.
//  Copyright © 2021 yuki. All rights reserved.
//

import AxDocument
import AppKit
import SwiftEx
import SnapKit
import AxComponents

final class AxHomeContentViewController: NSSplitViewController {
    private let sidebar = AxHomeSidebarViewControler()
    private let body = AxHomeRecentCollectionController()
        
    override func viewDidLoad() {
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebar)
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 240
        sidebarItem.maximumThickness = 360
        self.addSplitViewItem(sidebarItem)
        
        let bodyItem = NSSplitViewItem(viewController: body)
        bodyItem.canCollapse = false
        bodyItem.minimumThickness = 500
        self.addSplitViewItem(bodyItem)
    }
}

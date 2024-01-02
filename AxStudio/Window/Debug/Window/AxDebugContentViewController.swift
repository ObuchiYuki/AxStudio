//
//  AxDebugContentViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import SwiftEx
import AppKit
 
final class AxDebugContentViewController: NSSplitViewController {
    let sidebar = AxDebugSidebarViewController()
    let body = AxDebugBodyViewController()
    
    override func viewDidLoad() {
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebar)
        sidebarItem.minimumThickness = 0
        sidebarItem.canCollapse = false
        self.addSplitViewItem(sidebarItem)
        
        let bodyItem = NSSplitViewItem(viewController: body)
        bodyItem.minimumThickness = 320
        bodyItem.canCollapse = false
        self.addSplitViewItem(bodyItem)
    }
}

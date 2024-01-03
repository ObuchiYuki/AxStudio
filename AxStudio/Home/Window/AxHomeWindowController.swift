//
//  +AxHomeWindow.swift
//  AxComponents
//
//  Created by yuki on 2021/01/24.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import Combine
import AxDocument
import AxComponents
import KeychainAccess

final class AxHomeWindowController: NSWindowController {
    private var viewModel: AxHomeViewModel?
    
    private var homeContentViewController: AxHomeContentViewController {
        contentViewController as! AxHomeContentViewController
    }
    
    static var currentViewModel: AxHomeViewModel?
        
    override func windowDidLoad() {
        self.homeContentViewController.chainObject = Self.currentViewModel
        window?.setContentSize([1260, 780])
        window?.minSize = [800, 400]
        AxHomeWindowController.setInstantiatedController(self)
    }    
}

// Joinに必要
extension AxHomeWindowController {
    static func allInstantiatedControllers() -> [AxHomeWindowController] {
        self.allControllers
    }
    static func showAllInstantiatedControllers() {
        for controller in self.allControllers {
            controller.showWindow(nil)
        }
    }
    static func setInstantiatedController(_ wc: AxHomeWindowController) {
        self.allControllers.append(wc)
    }
    
    private static var allControllers = [AxHomeWindowController]()
}

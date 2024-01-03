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
        
    override func windowDidLoad() {
        guard let viewModel = viewModel else { assertionFailure("ViewModel is nil. Use AxHomeWindowController.init(viewModel:)"); return }
        self.homeContentViewController.chainObject = viewModel
        window?.setContentSize([1260, 780])
        window?.minSize = [800, 400]
        #if DEBUG
        AxHomeWindowController.__setInstantiatedController(self)
        #endif
    }
    
    convenience init(viewModel: AxHomeViewModel) {
        self.init()
        self.viewModel = viewModel
    }
}

#if DEBUG
extension AxHomeWindowController {
    static func __allInstantiatedControllers() -> [AxHomeWindowController] {
        self.__allControllers
    }
    static func __showAllInstantiatedControllers() {
        for controller in self.__allControllers {
            controller.showWindow(nil)
        }
    }
    static func __setInstantiatedController(_ wc: AxHomeWindowController) {
        self.__allControllers.append(wc)
    }
    
    private static var __allControllers = [AxHomeWindowController]()
}
#endif

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
    
    static var currentPresenter: AxHomeWindowPresenter!
        
    var presenter: AxHomeWindowPresenter!
    
    private var homeContentViewController: AxHomeContentViewController {
        contentViewController as! AxHomeContentViewController
    }
        
    override func windowDidLoad() {
        homeContentViewController.chainObject = presenter
        presenter.cloudDocumentManager.homeWindowController = self
        window?.setContentSize([1260, 780])
        window?.minSize = [800, 400]
        
        AxHomeWindowController.setInstantiatedController(self)
    }
    
    static func make(presenter: AxHomeWindowPresenter) -> AxHomeWindowController {
        Self.currentPresenter = presenter
        return NSStoryboard.main?.instantiateInitialController() as! AxHomeWindowController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.presenter = Self.currentPresenter
    }
}

extension AxHomeWindowController {
    static func allInstantiatedControllers() -> [AxHomeWindowController] {
        self._allControllers
    }
    static func showAllInstantiatedControllers() {
        print(_allControllers)
        for controller in self._allControllers {
            controller.showWindow(nil)
        }
    }
    static func setInstantiatedController(_ wc: AxHomeWindowController) {
        self._allControllers.append(wc)
    }
    
    private static var _allControllers = [AxHomeWindowController]()
}

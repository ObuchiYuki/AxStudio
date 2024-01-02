//
//  AxNodeViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/11/12.
//

import AppKit
import EmeralyUI
import BluePrintKit
import SwiftEx
import Combine

open class AxNodeViewController: NSViewController {
    var node: BPIONode?
    open func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {}
    
    private var nodeBag = Set<AnyCancellable>()
    
    private func commonInit() {
        self.getStatePublisher(for: .bluePrint).removeDuplicates(by: ===).compactMap{ $0 }
            .switchToLatest{ $0.$selectedNodes.compactMap{ $0.first } }
            .sink{[unowned self] in
                self.nodeBag.removeAll()
                self.node = $0
                self.nodeDidUpdate($0, objectBag: &self.nodeBag)
            }
            .store(in: &objectBag)
    }
    
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}


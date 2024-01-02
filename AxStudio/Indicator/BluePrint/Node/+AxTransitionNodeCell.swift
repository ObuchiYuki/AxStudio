//
//  +AxTransitionNode.swift
//  AxStudio
//
//  Created by yuki on 2022/01/04.
//

import BluePrintKit
import SwiftEx
import AppKit
import AxComponents
import Neontetra

final class AxTransitionNodeController: AxNodeViewController {
    private let cell = AxTransitionNode()
    
    override func loadView() { self.view = cell }
    
    override func nodeDidUpdate(_ node: BPIONode, objectBag: inout Bag) {
        guard let node = node as? BPTransitionNode else { return }
        
        node.$transitionType
            .sink{[unowned self] in cell.stylePicker.selectedItem = .identical($0) }.store(in: &objectBag)
        
        cell.stylePicker.itemPublisher
            .sink{[unowned self] v in document.execute{ node.transitionType = v } }.store(in: &objectBag)
    }
}

extension BPTransitionNode.TransitionType: ACTextItem {
    public static let allCases: [Self] = [.sheet, .fullscreen, .push]
    
    public var title: String {
        switch self {
        case .sheet: return "Modally"
        case .fullscreen: return "Replacing"
        case .push: return "Navigative"
        }
    }
}

final private class AxTransitionNode: ACGridView {
    let styleTitle = ACAreaLabel_(title: "Style")
    let stylePicker = ACEnumPopupButton_<BPTransitionNode.TransitionType>()
    
    override func onAwake() {
        self.addItem3(styleTitle, row: 0, column: 0)
        self.addItem3(stylePicker, row: 0, column: 1, length: 2)
        self.stylePicker.addItems(BPTransitionNode.TransitionType.allCases)
    }
}

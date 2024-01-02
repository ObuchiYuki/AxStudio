//
//  +AxBooleanCell.swift
//  AxStudio
//
//  Created by yuki on 2020/10/31.
//  Copyright © 2020 yuki. All rights reserved.
//

//import AxDocument
//import AxCommand
//import SwiftEx
import AppKit
//import AppKit
//import AxComponents
//import DesignKit
//
//class AxBooleanCellController: NSViewController {
//    private let cell = AxBooleanCell()
// 
//    override func loadView() { self.view = cell }
//
//    override func chainObjectDidLoad() {
//        document.$selectedLayers.switchToLatest { $0.map { $0.$booleanOperation }.combineLatest }.map { $0.mixture(.none) }
//            .sink{[unowned self] in cell.booleanPicker.state = $0 }.store(in: &objectBag)
//
//        cell.booleanPicker.itemPublisher
//            .sink{[unowned self] in execute(AxBooleanCommand(op: $0)) }.store(in: &objectBag)
//    }
//}
//
//extension DKBoolianOperation: ACImageItem {
//    public static var allCases: [Self] = [.none, .union, .subtract, .diffrence, .intersect]
//
//    public var image: NSImage {
//        switch self {
//        case .none: return NSImage(named: "__none")!
//        case .union: return NSImage(named: "__union")!
//        case .subtract: return NSImage(named: "__subtract")!
//        case .diffrence: return NSImage(named: "__diffrence")!
//        case .intersect: return NSImage(named: "__intersect")!
//        }
//    }
//}
//
//private class AxBooleanCell: ACStackViewCell {
//    let booleanPicker = ACSegmentedControl<DKBoolianOperation>()
//
//    override func initialHeight() -> CGFloat {
//        __ACLayout.cellHeight(stackY: 1)
//    }
//
//    override func layout() {
//        booleanPicker.controlFrame = __ACLayout.gridThree(x: 0, len: 3, in: bounds)
//    }
//
//    override func onAwake() {
//        self.addSubview(booleanPicker)
//    }
//}

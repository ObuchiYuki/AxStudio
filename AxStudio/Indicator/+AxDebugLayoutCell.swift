//
//  +AxDebugLayoutCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/20.
//

import AxComponents
import DesignKit
import AppKit
import SwiftEx
import AxCommand

final class AxDebugLayoutCellController: NSViewController {
    private let cell = AxDebugLayoutCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
//        let constraints = document.$selectedLayers.map{ $0.map{ $0.constraints } }
//
//        constraints.switchToLatest{ $0.map{ $0.$widthType }.combineLatest }.map{ $0.mixture(.auto) }
//            .sink{[unowned self] in cell.widthTypePicker.selectedItem = $0 }.store(in: &objectBag)
//        constraints.dynamicProperty(\.$widthValue, document: document)
//            .sink{[unowned self] in cell.widthValueField.setDynamicState($0); cell.widthTip.setDynamicState($0) }.store(in: &objectBag)
//
//        constraints.switchToLatest{ $0.map{ $0.$heightType }.combineLatest }.map{ $0.mixture(.auto) }
//            .sink{[unowned self] in cell.heightTypePicker.selectedItem = $0 }.store(in: &objectBag)
//        constraints.dynamicProperty(\.$heightValue, document: document)
//            .sink{[unowned self] in cell.heightValueField.setDynamicState($0); cell.heightTip.setDynamicState($0) }.store(in: &objectBag)
//
//        constraints.switchToLatest{ $0.map{ $0.$pinType }.combineLatest }.map{ $0.mixture(.positionValue) }
//            .sink{[unowned self] in cell.pinPicker.selectedItem = $0 }.store(in: &objectBag)
//        constraints.dynamicProperty(\.$xPinValue, document: document)
//            .sink{[unowned self] in cell.xPinField.setDynamicState($0); cell.xPinTip.setDynamicState($0) }.store(in: &objectBag)
//
//        constraints.dynamicProperty(\.$yPinValue, document: document)
//            .sink{[unowned self] in cell.yPinField.setDynamicState($0); cell.yPinTip.setDynamicState($0) }.store(in: &objectBag)
//
//        cell.widthTypePicker.itemPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.widthType = v } }.store(in: &objectBag)
//        cell.widthValueField.deltaPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.widthValue.update(v) } }.store(in: &objectBag)
//        cell.widthTip.commandPublisher
//            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Width", \DKLayer.constraints.widthValue)) }.store(in: &objectBag)
//
//        cell.heightTypePicker.itemPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.heightType = v } }.store(in: &objectBag)
//        cell.heightValueField.deltaPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.heightValue.update(v) } }.store(in: &objectBag)
//        cell.heightTip.commandPublisher
//            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Height", \DKLayer.constraints.heightValue)) }.store(in: &objectBag)
//
//        cell.pinPicker.itemPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.pinType = v } }.store(in: &objectBag)
//        cell.xPinField.deltaPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.xPinValue.update(v) } }.store(in: &objectBag)
//        cell.xPinTip.commandPublisher
//            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "X Position", \DKLayer.constraints.xPinValue)) }.store(in: &objectBag)
//
//        cell.yPinField.deltaPublisher
//            .sink{[unowned self] v in self.update{ $0.constraints.yPinValue.update(v) } }.store(in: &objectBag)
//        cell.yPinTip.commandPublisher
//            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Y Position", \DKLayer.constraints.yPinValue)) }.store(in: &objectBag)
    }
    
//    private func update(_ block: @escaping (DKLayer) -> ()) {
//        document.execute {
//            self.document.selectedLayers.forEach{ block($0) }
//        }
//    }
}

final private class AxDebugLayoutCell: ACGridView {
//    let widthTypePicker = ACEnumPopupButton_<DKConstraints.LengthType>()
//    let widthValueField = ACNumberField_().slider()
//    let widthTip = ACDynamicTip.autoconnect(.float)
//
//    let heightTypePicker = ACEnumPopupButton_<DKConstraints.LengthType>()
//    let heightValueField = ACNumberField_().slider()
//    let heightTip = ACDynamicTip.autoconnect(.float)
//
//    let pinPicker = ACEnumPopupButton_<DKConstraints.PinType>()
//    let xPinField = ACNumberField_().slider()
//    let xPinTip = ACDynamicTip.autoconnect(.float)
//
//    let yPinField = ACNumberField_().slider()
//    let yPinTip = ACDynamicTip.autoconnect(.float)
//
//    override func onAwake() {
//        self.addItem3(widthTypePicker, row: 0, column: 0, length: 2)
//        self.widthTypePicker.addItems(DKConstraints.LengthType.allCases)
//        self.addItem3(widthValueField, row: 0, column: 2, decorator: widthTip)
//
//        self.addItem3(heightTypePicker, row: 1, column: 0, length: 2)
//        self.heightTypePicker.addItems(DKConstraints.LengthType.allCases)
//        self.addItem3(heightValueField, row: 1, column: 2, decorator: heightTip)
//
//        self.addItem3(pinPicker, row: 2, column: 0, length: 2)
//        self.pinPicker.addItems(DKConstraints.PinType.allCases)
//        self.addItem3(xPinField, row: 2, column: 2, decorator: xPinTip)
//        self.addItem3(yPinField, row: 3, column: 2, decorator: yPinTip)
//    }
}
 


//extension DKConstraints.LengthType: ACTextItem {
//    public static var allCases: [Self] = [.auto, .ratio, .value]
//    public var title: String {
//        switch self { case .auto: return "Auto" case .ratio: return "Ratio" case .value: return "Value" }
//    }
//}
//
//extension DKConstraints.PinType: ACTextItem {
//    public static var allCases: [Self] = [.positionValue, .offsetValue, .positionRatio, .offsetRatio]
//    public var title: String {
//        switch self {
//        case .positionValue: return "Position Value"
//        case .offsetValue: return "Offset Value"
//        case .positionRatio: return "Position Ratio"
//        case .offsetRatio: return "Offset Ratio"
//        }
//    }
//}

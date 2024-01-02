//
//  +AxCornerRadiusCell.swift
//  AxStudio
//
//  Created by yuki on 2020/07/01.
//  Copyright © 2020 yuki. All rights reserved.
//

import AxComponents
import AppKit
import AxDocument
import DesignKit
import SwiftEx
import AxCommand
import BluePrintKit

class AxCornerRadiusCellController: NSViewController {
    private let cell = AxCornerRadiusCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let rectangles = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKCornerRadiusLayerType } }
        let cornerRadiuses = rectangles.map{ $0.map{ $0.cornerRadius } }
        let cornerType = cornerRadiuses.switchToLatest{ $0.map{ $0.$cornerType }.combineLatest }.map{ $0.mixture(.fixedSize) }.removeDuplicates()
        let cornerRaius = cornerRadiuses.dynamicProperty(\.$radius, document: document).removeDuplicates()
        
        cornerType.sink{[unowned self] in self.cell.cornerTypeButton.selectedItem = $0 }.store(in: &objectBag)
        cornerType.map{ $0 != .identical(.fixedSize) }
            .sink{[unowned self] in self.cell.radiusField.isHidden = $0; self.cell.radiusTip.isHidden = $0 }.store(in: &objectBag)
        
        cornerRaius.sink{[unowned self] in self.cell.radiusField.setDynamicState($0) }.store(in: &objectBag)
        cornerRaius.sink{[unowned self] in self.cell.radiusTip.setDynamicState($0) }.store(in: &objectBag)

        cell.radiusField.phasePublisher
            .sink{[unowned self] in document.execute(AxCornerRadiusCommand($0)) }.store(in: &objectBag)
        cell.radiusField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \DKCornerRadiusLayerType.cornerRadius.radius)) }.store(in: &objectBag)
        cell.cornerTypeButton.itemPublisher
            .sink{[unowned self] in document.execute(AxCornerTypeCommand($0)) }.store(in: &objectBag)
        cell.radiusTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Corner radius", \DKCornerRadiusLayerType.cornerRadius.radius)) }.store(in: &objectBag)
    }
}

final private class AxCornerRadiusCell: ACGridView {
    let cornerTypeButton = ACEnumPopupButton_<DKCornerRadius.CornerType>()
    let radiusField = ACNumberField_(stateDrop: true).slider() => { $0.unit = "px" }
    let radiusTip = ACDynamicTip.autoconnect(.float)

    override func onAwake() {
        self.cornerTypeButton.addItems(DKCornerRadius.CornerType.allCases)
        self.addItem3(cornerTypeButton, row: 0, column: 0, length: 2)
        self.addItem3(radiusField, row: 0, column: 2, decorator: radiusTip)
    }
}

extension DKCornerRadius.CornerType: ACTextItem {
    public static let allCases = [Self.capsule, .fixedSize]
    
    public var title: String {
        switch self {
        case .capsule: return "Capsule"
        case .fixedSize: return "Fixed Radius"
        }
    }
}

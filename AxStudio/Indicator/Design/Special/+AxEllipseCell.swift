//
//  +AxEllipseCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/10.
//

import AxComponents
import AppKit
import AxDocument
import DesignKit
import SwiftEx
import AppKit
import AxCommand
import BluePrintKit

final class AxEllipseCellController: NSViewController {
    private let cell = AxEllipseCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let ellipses = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKEllipse } }
        
        ellipses.switchToLatest{ $0.map{ $0.$shapeType }.combineLatest }.map{ $0.mixture(.ellipse) }
            .sink{[unowned self] in self.cell.shapeTypeButton.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.shapeTypeButton.itemPublisher
            .sink{[unowned self] in document.execute(AxEllipseShapeTypeCommand($0)) }.store(in: &objectBag)
    }
}

final private class AxEllipseCell: ACGridView {
    let shapeTypeTitle = ACAreaLabel_(title: "Shape Type")
    let shapeTypeButton = ACEnumPopupButton_<DKEllipse.ShapeType>()

    override func onAwake() {
        self.shapeTypeButton.addItems(DKEllipse.ShapeType.allCases)
        
        self.addItem3(shapeTypeTitle, row: 0, column: 0)
        self.addItem3(shapeTypeButton, row: 0, column: 1, length: 2)
    }
}

extension DKEllipse.ShapeType: ACTextItem {
    public static let allCases: [Self] = [.circle, .ellipse]
    
    public var title: String {
        switch self {
        case .circle: return "Circle"
        case .ellipse: return "Ellipse"
        }
    }
}

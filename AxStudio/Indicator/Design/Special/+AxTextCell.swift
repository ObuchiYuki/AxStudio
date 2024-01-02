//
//  +AxTextCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/12.
//

import AxComponents
import AxDocument
import DesignKit
import SwiftEx
import AppKit
import AxCommand
import BluePrintKit
import Combine

final class AxTextCellController: NSViewController {
    private let cell = AxTextCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let textLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKTextLayer } }
        let textValue = textLayers.dynamicProperty(\.$string, document: document)
        let font = textLayers.switchToLatest{[unowned self] in $0.map{ $0.fontProvider.fontp(self.document.session) }.combineLatest }
        let fills = textLayers.map{ $0.map{ $0.style.fill } }
        let fillColor = fills.dynamicProperty(\DKStyleSolidFill.$color, document: document)
        let alignment = textLayers.switchToLatest{ $0.map{ $0.$alignment }.combineLatest }.map{ $0.mixture(.left) }
        let charSpacing = textLayers.switchToLatest{ $0.map{ $0.$charSpacing }.combineLatest }.map{ $0.mixture }
        let lineSpacing = textLayers.switchToLatest{ $0.map{ $0.$lineSpacing }.combineLatest }.map{ $0.mixture }
        
        textValue
            .sink{[unowned self] in cell.textField.setDynamicState($0) }.store(in: &objectBag)
        textValue
            .sink{[unowned self] in cell.textTip.setDynamicState($0) }.store(in: &objectBag)
        
        font.map{ $0.map{ $0.family }.mixture(.error) }
            .sink{[unowned self] in cell.fontWell.family = $0 }.store(in: &objectBag)
        font.map{ $0.map(\.size).mixture }
            .sink{[unowned self] in cell.fontSizeField.fieldValue = $0 }.store(in: &objectBag)
        font
            .sink{[unowned self] in cell.fontWeightPicker.state = .init($0) }.store(in: &objectBag)
        fillColor
            .sink{[unowned self] in cell.colorWell.setDynamicColor($0) }.store(in: &objectBag)
        fillColor
            .sink{[unowned self] in cell.colorTip.setDynamicState($0) }.store(in: &objectBag)
        alignment
            .sink{[unowned self] in cell.alignmentSelector.selectedEnumItem = $0 }.store(in: &objectBag)
        charSpacing
            .sink{[unowned self] in cell.charSpacing.fieldValue = $0 }.store(in: &objectBag)
        lineSpacing
            .sink{[unowned self] in cell.lineSpacing.fieldValue = $0 }.store(in: &objectBag)
        
        // MARK: - Output -
        cell.fontWell.familyPublisher
            .sink{[unowned self] in document.execute(AxFontFamilyCommand(family: $0)) }.store(in: &objectBag)
        cell.fontSizeField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxFontSizeCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.fontWeightPicker.weightPublisher
            .sink{[unowned self] in document.execute(AxFontWeightCommand($0)) }.store(in: &objectBag)
        cell.colorWell.colorPublisher
            .sink{[unowned self] in document.session.broadcast(AxTextFillColorCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.colorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \DKTextLayer.style.fill.color)) }.store(in: &objectBag)
        cell.colorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\DKTextLayer.style.fill.color)) }.store(in: &objectBag)
        cell.colorTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "text color", \DKTextLayer.style.fill.color)) } .store(in: &objectBag)
        cell.textField.endPublisher
            .sink{[unowned self] in document.session.broadcast(AxTextCommand.once(nil, with: $0)) }.store(in: &objectBag)
        cell.textTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "text", \DKTextLayer.string)) } .store(in: &objectBag)
        cell.alignmentSelector.itemPublisher
            .sink{[unowned self] in document.execute(AxTextAlignmentCommand(alignment: $0)) }.store(in: &objectBag)
        cell.fontDragpad.fontPublisher
            .sink{[unowned self] in document.execute(AxFontProviderBecomeFontCommand($0)) }.store(in: &objectBag)
        cell.fontDragpad.assetPublisher
            .sink{[unowned self] in document.execute(AxFontProviderBecomeAssetCommand($0)) }.store(in: &objectBag)
        
        cell.charSpacing.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxTextCharSpacingCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.lineSpacing.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxTextLineSpacingCommand.fromPhase($0)) }.store(in: &objectBag)
    }
}

final private class AxTextCell: ACGridView {
    let textField = ACTextField_()
    let textTip = ACDynamicTip.autoconnect(.string)
    
    let fontWell = ACFontFamilyWell()
    let fontSizeField = ACNumberField_() => { $0.unit = "pt" }
    let fontWeightPicker = ACFontWeightPicker()
    let colorWell = ACColorWell().autoconnectLibrary()
    let colorTip = ACDynamicTip.autoconnect(.color)
    let fontDragpad = ACFontDroppad()
    
    let lineSpacing = ACNumberField_().slider(scale: 0.05, intOnly: false) => { $0.icon = R.Image.lineSpacing }
    let charSpacing = ACNumberField_().slider(scale: 0.05, intOnly: false) => { $0.icon = R.Image.charSpacing }
    
    let alignmentSelector = ACEnumSegmentedControl<DKTextAlignment>()
    let valignmentSelector = ACEnumSegmentedControl<DKTextVerticalAlignment>()
    
    override func onAwake() {
        fontSizeField.additionalControl = ACNumberFieldPopup_.textSizes()
        
        self.addItem3(textField, row: 0, column: 0, length: 3, decorator: textTip)
        self.textField.showIcon = true
        
        self.addItem3(fontDragpad, row: 1, column: 0, length: 3)
        
        self.addItem3(fontWell, row: 1, column: 0, length: 2)
        self.addItem3(fontSizeField, row: 1, column: 2)
        self.addItem3(fontWeightPicker, row: 2, column: 0, length: 2)
        self.addItem3(colorWell, row: 2, column: 2, decorator: colorTip)
        
        self.addItem4(alignmentSelector, row: 3, column: 0, length: 2)
        self.alignmentSelector.addItems(DKTextAlignment.allCases)
        
        self.addItem4(lineSpacing, row: 3, column: 2)
        self.addItem4(charSpacing, row: 3, column: 3)
        
        self.addItem4(ACControlLabel("Alignment"), row: 3.9, column: 0, length: 2)
        self.addItem4(ACControlLabel("Line"), row: 3.9, column: 2)
        self.addItem4(ACControlLabel("Char"), row: 3.9, column: 3)
        
        self.gridHeight -= 0.4
    }
}

extension ACNumberFieldPopup_ {
    static func textSizes() -> ACNumberFieldPopup_ {
        let popup = ACNumberFieldPopup_()
        for size in [6, 7, 8, 9, 10, 11, 12, 14, 16, 18, 21, 24, 36, 48, 60, 72] {
            popup.addItem("\(size) pt", for: CGFloat(size))
        }
        return popup
    }
}

extension DKTextVerticalAlignment: ACImageItem {
    public static var allCases: [Self] = [.top, .center, .bottom]
    
    public var image: NSImage {
        switch self {
        case .top: return R.Image.valignTop
        case .center: return R.Image.valignCenter
        case .bottom: return R.Image.valignBottom
        }
    }
}

private typealias TAl = R.I.Image.TextAlign
extension DKTextAlignment: ACImageItem {
    public static var allCases: [Self] = [.left, .center, .right, .justified]

    public var image: NSImage { [.left: TAl.left, .center: TAl.center, .right: TAl.right, .justified: TAl.justify][self]! }
}

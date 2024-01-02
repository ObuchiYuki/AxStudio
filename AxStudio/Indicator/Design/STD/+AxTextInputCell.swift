//
//  +AxTextInputCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/15.
//

import SwiftEx
import STDComponents
import AxDocument
import BluePrintKit
import DesignKit
import AxComponents
import AxCommand

final class AxTextInputCellController: NSViewController {
    private let cell = AxTextInputCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let textInputs = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? STDTextInput } }
        
        let textValue = textInputs.dynamicProperty(\.$text, document: document).removeDuplicates()
        let textColorValue = textInputs.dynamicProperty(\.$textColor, document: document)
        let placeholder = textInputs.switchToLatest{ $0.map{ $0.$placeholder }.combineLatest }.map{ $0.mixture }.removeDuplicates()
        let font = textInputs.switchToLatest{ $0.map{ $0.fontProvider.fontp }.combineLatest }
        let alignment = textInputs.switchToLatest{ $0.map{ $0.$alignment }.combineLatest }.map{ $0.mixture(.left) }.removeDuplicates()
        let contentType = textInputs.switchToLatest{ $0.map{ $0.$contentType }.combineLatest }.map{ $0.mixture(.none) }.removeDuplicates()
        let isBordered = textInputs.switchToLatest{ $0.map{ $0.$isBordered }.combineLatest }.map{ $0.mixture }.removeDuplicates()
        
        textValue
            .sink{[unowned self] in cell.textField.setDynamicState($0) }.store(in: &objectBag)
        textValue
            .sink{[unowned self] in cell.textTip.setDynamicState($0) }.store(in: &objectBag)
        textColorValue
            .sink{[unowned self] in cell.textColorWell.setDynamicColor($0) }.store(in: &objectBag)
        textColorValue
            .sink{[unowned self] in cell.textColorWellTip.setDynamicState($0) }.store(in: &objectBag)
        
        placeholder
            .sink{[unowned self] in cell.placeholderField.fieldState = $0 }.store(in: &objectBag)
        font.map{ $0.mixture(.systemDefault) }.removeDuplicates()
            .sink{[unowned self] in cell.fontWell.family = $0.map{ $0.family } }.store(in: &objectBag)
        font
            .sink{[unowned self] in cell.fontWeightPicker.state = .init($0) }.store(in: &objectBag)
        font.map{ $0.map{ $0.size }.mixture }
            .sink{[unowned self] in cell.fontSizeSelector.fieldValue = $0 }.store(in: &objectBag)
        alignment
            .sink{[unowned self] in cell.alignmentSelector.selectedEnumItem = $0 }.store(in: &objectBag)
        contentType
            .sink{[unowned self] in cell.contentTypePicker.selectedItem = $0 }.store(in: &objectBag)
        isBordered
            .sink{[unowned self] in cell.borderedCheck.checkState = $0 }.store(in: &objectBag)
        
        self.cell.textField.endPublisher
            .sink{[unowned self] in document.execute(AxTextInputTextCommand($0)) }.store(in: &objectBag)
        self.cell.textField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDTextInput.text)) }.store(in: &objectBag)
        self.cell.textTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Input Text", \STDTextInput.text)) }.store(in: &objectBag)
        self.cell.placeholderField.endPublisher
            .sink{[unowned self] in document.execute(AxTextInputPlaceholderCommand($0)) }.store(in: &objectBag)
        self.cell.fontWell.familyPublisher
            .sink{[unowned self] in document.execute(AxTextInputFontFamilyCommand($0)) }.store(in: &objectBag)
        self.cell.fontSizeSelector.phasePublisher
            .sink{[unowned self] in document.execute(AxTextInputTextSizeCommand($0)) }.store(in: &objectBag)
        self.cell.fontWeightPicker.weightPublisher
            .sink{[unowned self] in document.execute(AxTextInputFontWeightCommand($0)) }.store(in: &objectBag)
        
        self.cell.textColorWell.colorPublisher
            .sink{[unowned self] in document.execute(AxTextInputTextColorCommand($0)) }.store(in: &objectBag)
        self.cell.textColorWell.colorConstantPublisher
            .sink{[unowned self] in document.execute(AxLinkToConstantCommand($0, \STDTextInput.textColor)) }.store(in: &objectBag)
        self.cell.textColorWell.colorStatePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDTextInput.textColor)) }.store(in: &objectBag)
        self.cell.textColorWell.deattchConstantPublisher
            .sink{[unowned self] in document.execute(AxBecomeStaticCommand(\STDTextInput.textColor)) }.store(in: &objectBag)
        
        self.cell.textColorWellTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "Text Color", \STDTextInput.textColor)) }.store(in: &objectBag)
        self.cell.alignmentSelector.itemPublisher
            .sink{[unowned self] in document.execute(AxTextInputAlignmentCommand($0)) }.store(in: &objectBag)
        self.cell.contentTypePicker.itemPublisher
            .sink{[unowned self] in document.execute(AxTextInputContentTypeCommand($0)) }.store(in: &objectBag)
        self.cell.borderedCheck.checkPublisher
            .sink{[unowned self] in document.execute(AxTextInputIsBorderedTypeCommand($0)) }.store(in: &objectBag)
    }
}

final private class AxTextInputCell: ACGridView {
    private let textTitle = ACAreaLabel_(title: "Text")
    let textField = ACTextField_(stateDrop: true)
    let textTip = ACDynamicTip.autoconnect(.string)
    
    private let placeholderTitle = ACAreaLabel_(title: "Placeholder")
    let placeholderField = ACTextField_()
    
    let fontWell = ACFontFamilyWell()
    let fontSizeSelector = ACNumberField_().stepper()
    
    let fontWeightPicker = ACFontWeightPicker()
    let textColorWell = ACColorWell().autoconnectLibrary()
    let textColorWellTip = ACDynamicTip.autoconnect(.color)
    
    private let alignmentTitle = ACAreaLabel_(title: "Alignment")
    let alignmentSelector = ACEnumSegmentedControl<DKTextAlignment>()
    
    private let contentTypeTitle = ACAreaLabel_(title: "Type")
    let contentTypePicker = ACEnumPopupButton_<STDTextInput.ContentType>()
    
    let borderedCheck = ACCheckBoxAndTitle(title: "Is Bordered")
        
    override func onAwake() {
        self.addItem3(textTitle, row: 0, column: 0)
        self.addItem3(textField, row: 0, column: 1, length: 2, decorator: textTip)
        self.textField.showIcon = true
        
        self.addItem3(placeholderTitle, row: 1, column: 0, length: 2)
        self.addItem3(placeholderField, row: 1, column: 1, length: 2)
        self.placeholderField.showIcon = true
        
        self.addItem3(fontWell, row: 2, column: 0, length: 2)
        self.addItem3(fontSizeSelector, row: 2, column: 2)
        self.fontSizeSelector.additionalControl = ACNumberFieldPopup_.textSizes()
        
        self.addItem3(fontWeightPicker, row: 3, column: 0, length: 2)
        self.addItem3(textColorWell, row: 3, column: 2, decorator: textColorWellTip)
        
        self.addItem3(alignmentTitle, row: 4, column: 0)
        self.addItem3(alignmentSelector, row: 4, column: 1, length: 2)
        self.alignmentSelector.addItems(DKTextAlignment.allCases)
        
        self.addItem3(contentTypeTitle, row: 5, column: 0)
        self.addItem3(contentTypePicker, row: 5, column: 1, length: 2)
        self.contentTypePicker.addItems(STDTextInput.ContentType.allCases)
        
        self.addItem3(borderedCheck, row: 6, column: 0, length: 3)        
    }
}


extension STDTextInput.ContentType: ACTextItem {
    public var title: String {
        switch self {
        case .none: return "none.input".locarized()
        case .name: return "name.input".locarized()
        case .number: return "number.input".locarized()
        case .address: return "address.input".locarized()
        case .telephone: return "telephone.input".locarized()
        case .email: return "email.input".locarized()
        case .creditCard: return "creditCard.input".locarized()
        case .username: return "username.input".locarized()
        case .password: return "password.input".locarized()
        case .newPassword: return "newPassword.input".locarized()
        }
    }
}






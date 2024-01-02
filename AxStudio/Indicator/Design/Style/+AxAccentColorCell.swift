//
//  +AxAccentColorCell.swift
//  AxStudio
//
//  Created by yuki on 2021/12/19.
//

import AxDocument
import AxCommand
import DesignKit
import SwiftEx
import STDComponents
import AxComponents

final class AxAccentColorCellController: NSViewController {
    private let cell = AxAccentColorCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        cell.colorWell.library = document.standardColorLibrary
        
        document.rootNode.constantStorage.accentColor.$value.compactMap{ $0 as? DKColor }
            .sink{[unowned self] in cell.colorWell.color = .identical($0); cell.hexField.fieldValue = .identical($0.rgb) }
            .store(in: &objectBag)
        
        cell.colorWell.colorPublisher.compactMap{ $0.value }
            .sink{[unowned self] v in document.execute { document.rootNode.constantStorage.accentColor.value = v } }
            .store(in: &objectBag)
        cell.hexField.valuePublisher
            .sink{[unowned self] v in document.execute { document.rootNode.constantStorage.accentColor.value = DKColor(rgb: v, alpha: 1) } }
            .store(in: &objectBag)
    }
}

final private class AxAccentColorCell: ACGridView {
    let colorWell = ACColorWell(options: [.color, .constant, .opacity])
    let hexField = ACHexColorField()
    
    override func onAwake() {
        self.addItem3(colorWell, row: 0, column: 0)
        self.addItem3(hexField, row: 0, column: 1)
    }
}

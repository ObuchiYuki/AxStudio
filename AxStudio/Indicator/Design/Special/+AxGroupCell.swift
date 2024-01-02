//
//  +AxGroupCell.swift
//  AxStudio
//
//  Created by yuki on 2021/10/25.
//

import AxComponents
import AppKit
import AxDocument
import DesignKit
import AxCommand
import SwiftEx
import AppKit

final class AxGroupCellController: NSViewController {
    private let cell = AxGroupCell()
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        let groups = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKGroup } }
        let isMask = groups.switchToLatest{ $0.map{ $0.$isMask }.combineLatest }.map{ $0.mixture }
        let autoResize = groups.switchToLatest{ $0.map{ $0.$autoResize }.combineLatest }.map{ $0.mixture }
            
        isMask
            .sink{[unowned self] in cell.maskCheckbox.checkState = $0 }.store(in: &objectBag)
        autoResize
            .sink{[unowned self] in cell.autoResizeCheck.checkState = $0 }.store(in: &objectBag)
        
        cell.maskCheckbox.checkPublisher
            .sink{[unowned self] in document.execute(AxGroupIsMaskCommand($0)) }.store(in: &objectBag)
        cell.autoResizeCheck.checkPublisher
            .sink{[unowned self] in document.execute(AxGroupAutoResizeCommand($0)) }.store(in: &objectBag)
        cell.stackButton.actionPublisher
            .sink{[unowned self] in document.execute(AxGroupToStackCommand()) }.store(in: &objectBag)
    }
}

final private class AxGroupCell: ACGridView {
    let autoResizeCheck = ACCheckBoxAndTitle(title: "Auto resize")
    let maskCheckbox = ACCheckBoxAndTitle(title: "Mask to bounds")
    let stackButton = ACTitleButton_(title: "Become stack", image: R.Image.stackVertical)
    
    override func onAwake() {
        self.addItem3(maskCheckbox, row: 0, column: 0, length: 3)
        self.addItem3(autoResizeCheck, row: 1, column: 0, length: 3)
        self.addItem3(stackButton, row: 2, column: 0, length: 3)
    }
}

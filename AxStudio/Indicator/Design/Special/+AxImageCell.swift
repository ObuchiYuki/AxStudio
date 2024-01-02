//
//  +ASImageCell.swift
//  AxStudio
//
//  Created by yuki on 2020/11/24.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import DesignKit
import AxDocument
import AxCommand
import SwiftEx
import AxComponents

final class AxImageCellController: NSViewController {
    private let cell = AxImageCell()
    
    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        // MARK: - Input -
        let imageLayers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ ($0 as? DKImageLayer) } }
        let imageValue = imageLayers.dynamicProperty(\.$image, document: document)
        let contentMode = imageLayers.switchToLatest{ $0.map{ $0.$contentMode }.combineLatest }.map{ $0.mixture(.aspectFill) }
        
        imageValue.sink{[unowned self] in cell.imageWell.setDynamicState($0) }.store(in: &objectBag)
        imageValue.sink{[unowned self] in cell.imageTip.setDynamicState($0) }.store(in: &objectBag)
            
        contentMode
            .sink {[unowned self] in cell.contentModePicker.selectedItem = $0 }.store(in: &objectBag)

        // MARK: - Output -
        cell.imageWell.imagePublisher
            .sink {[unowned self] in execute(AxImageCommand($0, filename: $1)) }.store(in: &objectBag)
        cell.imageTip.commandPublisher
            .sink {[unowned self] in execute(AxDynamicLayerPropertyCommand($0, "image", \DKImageLayer.image)) }.store(in: &objectBag)
        cell.contentModePicker.itemPublisher
            .sink {[unowned self] in execute(AxImageContentModeCommand(mode: $0)) }.store(in: &objectBag)
    }
}

final private class AxImageCell: ACGridView {
    let imageWell = ACImageWell()
    let imageTip = ACDynamicTip.autoconnect(.image)
    let contentModePicker = ACEnumPopupButton_<DKContentMode>()

    override func onAwake() {
        self.contentModePicker.addItems(DKContentMode.allCases)
        
        self.addItem3(imageWell, row: 0, column: 0, decorator: imageTip)
        self.addItem3(contentModePicker, row: 0, column: 1, length: 2)
    }
}

extension DKContentMode: ACTextItem {
    public static var allCases: [Self] = [.aspectFill, .aspectFit, .scaleToFill]

    public var title: String {
        switch self {
        case .aspectFill: return "Aspect Fill"
        case .aspectFit: return "Aspect Fit"
        case .scaleToFill: return "Scale To Fill"
        }
    }
}

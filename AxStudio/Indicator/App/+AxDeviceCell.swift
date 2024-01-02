//
//  +AxDevice.swift
//  AxStudio
//
//  Created by yuki on 2020/11/02.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxDocument
import AxCommand
import SwiftEx
import AppKit
import AxModelCore
import DesignKit
import AxComponents

final class AxDeviceCellController: NSViewController {
    private let cell = AxDeviceCell()

    override func loadView() { self.view = cell }

    override func chainObjectDidLoad() {
        document.rootNode.appFile.$screenSize
            .sink{[unowned self] in
                cell.directionPicker.selectedEnumItem = .identical($0.direction)
                cell.screenSizeWell.screenSize = $0
            }
            .store(in: &objectBag)

        cell.directionPicker.itemPublisher
            .sink{[unowned self] in document.execute(AxScreenDirectionCommand($0)) }.store(in: &objectBag)
        cell.screenSizeWell.screenClassPublisher
            .sink{[unowned self] in document.execute(AxScreenClassCommand($0)) }.store(in: &objectBag)
    }
}

final private class AxDeviceCell: ACGridView {
    let screenSizeWell = ACScreenSizeWell()
    let directionPicker = ACEnumSegmentedControl<DKScreenDirection>()
    
    override func onAwake() {
        self.addItem3(screenSizeWell, row: 0, column: 0, length: 2)
        
        self.addItem3(directionPicker, row: 0, column: 2)
        self.directionPicker.addItems(DKScreenDirection.allCases)
    }
}

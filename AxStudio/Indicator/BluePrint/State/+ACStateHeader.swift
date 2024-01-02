//
//  +ACStateHeader.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import AxComponents
import SwiftEx
import AppKit
import AxCommand
import DesignKit

final class ACStateHeaderController: ACStackViewFoldHeaderController {
    private let addStateButton = ACImageButton_(image: R.Image.lightAddBtton)
    
    override func viewDidLoad() {
        self.insertAttributeView(addStateButton, at: 0)
        self.addStateButton.snp.makeConstraints{ make in
            make.size.equalTo(20)
        }
    }
    
    override func chainObjectDidLoad() {
        self.addStateButton.actionPublisher
            .sink{[unowned self] in addState() }.store(in: &objectBag)
        
        document.$selectedLayers
            .sink{[unowned self] in self.updateTitle(with: $0) }.store(in: &objectBag)
    }
    
    private func updateTitle(with layers: [DKLayer]) {
        if layers.count == 0 {
            return self.title = "?"
        } else if layers.count == 1, let layer = layers.first {
            if layer.componentLayer != nil {
                self.title = "States"
            } else if layer.viewModelLayer != nil {
                self.title = "States"
            } else {
                self.title = "?"
            }
        } else {
            self.title = "?"
        }
    }
    
    private func addState() {
        let picker = ACTypePicker(document)
        picker.show(on: addStateButton)
        picker.typePublisher
            .sink{[unowned self] in document.execute(AxMakeStateCommand($0)) }.store(in: &objectBag)

    }
}

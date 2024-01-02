//
//  +AxActionHeader.swift
//  AxStudio
//
//  Created by yuki on 2021/12/09.
//

import AxDocument
import SwiftEx
import AppKit
import DesignKit
import BluePrintKit
import AxComponents
import AxCommand

final class AxActionHeaderController: ACStackViewFoldHeaderController {
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
    }
    
    private func addState() {
        guard let window = self.view.window else { return __warn_ifDebug_beep_otherwise() }
        guard let viewModel = document.selectedLayers.first?.viewModelLayer?.viewModel else { return __warn_ifDebug_beep_otherwise() }
        
        let defaultName = Identifier.make(with: .numberPostfix("Action"), notContainsIn: Set(viewModel.actions.map{ $0.name }))
        let alert = NSAlert.singleTextInput(window, defaultValue: defaultName, placeholder: "Action name") { name in
            self.document.execute(AxMakeActionCommand(name))
        }
        alert.messageText = "Create new Action"
    }
}

//
//  +AxBluePrintView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/10.
//

import EmeralyUI
import SwiftEx
import AppKit
import AxDocument
import AxComponents
import AxCommand
import BluePrintKit
import AppKit

final class AxBluePrintEditorViewController: EMEditorViewController {
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        
        document.currentNodeContainerp
            .sink{[unowned self] in self.updateContainer($0) }.store(in: &objectBag)
        
        self.viewDidLayout()
    }
    
    private func updateContainer(_ container: BPContainer?) {
        self.setState(container, for: .bluePrint)
        if container == nil { return }
        
        if container is BPExpression {
            self.setState(AxBluePrintNodeLibraryBuilder.expressionLibrary, for: .nodePickerLibrary)
        } else if container is BPStatement {
            self.setState(AxBluePrintNodeLibraryBuilder.statementLibrary, for: .nodePickerLibrary)
        } else {
            assertionFailure("Unkown container type '\(type(of: container))'")
        }
    }
    
    override func viewDidLayout() {
        document?.execute(AxBluePrintViewSizeCommand(size: view.frame.size))
    }
    
    @IBAction func copy(_ sender: Any) {
        guard let container = self.container else { return }
        document.execute(AxCopyNodeCommand(container))
    }
    @IBAction func paste(_ sender: Any) {
        guard let container = self.container else { return }
        document.execute(AxPasteNodeCommand(container))
    }
    @IBAction func cut(_ sender: Any) {
        guard let container = self.container else { return }
        document.execute(AxCutNodeCommand(container))
    }
    @IBAction func duplicate(_ sender: Any) {
        guard let container = self.container else { return }
        document.execute(AxDuplicateNodeCommand(container))
    }
    @IBAction func delete(_ sender: Any) {
        guard let container = self.container else { return }
        document.execute(AxDeleteNodeCommand(container))
        document.execute(AxDeleteWireCommand(container))
    }
}

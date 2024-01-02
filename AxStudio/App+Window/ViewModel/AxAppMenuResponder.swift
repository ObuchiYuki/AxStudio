//
//  AxAppMenuResponder.swift
//  AxStudio
//
//  Created by yuki on 2021/11/11.
//

import AppKit
import AxDocument
import AxCommand
import DesignKit
import BluePrintKit

final class AxAppMenuResponder: NSResponder {
    override var acceptsFirstResponder: Bool { true }
    
    private let document: AxDocument
    
    init(_ document: AxDocument) {
        self.document = document
        super.init()
    }

    
    @IBAction func undo(_ menu: Any) {
        print(#function, self)
    }
    @IBAction func redo(_ menu: Any) {
        print(#function, self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


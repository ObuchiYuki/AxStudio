//
//  AxLocalColorItem.swift
//  AxStudio
//
//  Created by yuki on 2021/12/04.
//

import AxDocument
import AxComponents
import DesignKit
import BluePrintKit
import SwiftEx
import AppKit
import Combine
import AxCommand

final public class AxLocalColorItem: ACColorItem {
    public let canReorder: Bool
    public let canRename: Bool
    public let canRemove: Bool
    public let itemType: DKFillType = .color
    public var namep: AnyPublisher<String, Never> { constant.$name.eraseToAnyPublisher() }
    public var colorp: AnyPublisher<DKColor, Never> { constant.$value.compactMap{ $0 as? BPColor }.eraseToAnyPublisher() }
    
    public func onRemoveItem() {
        document.execute(AxRemoveColorConstantsCommand([constant]))
    }
    public func onSelect(with model: ACColorPickerModel) {
        model.colorConstantPublisher.send(constant)
    }
    public func pasteboardWriter() -> NSPasteboardWriting? {
        constant.pasteBoardRefStorage(forType: .bpConstant)
    }
    
    let constant: BPConstant
    let document: AxDocument
    
    init(_ constant: BPConstant, document: AxDocument) {
        self.constant = constant
        self.document = document
        
        self.canReorder = true
        self.canRename = true
        self.canRemove = true
    }
    
    init(accent constant: BPConstant, document: AxDocument) {
        self.constant = constant
        self.document = document
        
        self.canReorder = false
        self.canRename = false
        self.canRemove = false
    }
}

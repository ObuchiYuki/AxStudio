//
//  AxLocalGradientItem.swift
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

final public class AxLocalGradientItem: ACColorItem {
    public let canReorder: Bool = true
    public let canRename: Bool = true
    public let canRemove: Bool = true
    public let itemType: DKFillType = .gradient
    public var namep: AnyPublisher<String, Never> { constant.$name.eraseToAnyPublisher() }
    public var colorp: AnyPublisher<DKColor, Never> { Empty().eraseToAnyPublisher() }
    public var gradientp: AnyPublisher<DKGradient, Never> { constant.$value.compactMap{ $0 as? BPGradient }.eraseToAnyPublisher() }
    
    let document: AxDocument
    let constant: BPConstant
    
    public func onRemoveItem() {
        document.execute(AxRemoveColorConstantsCommand([constant]))
    }
    public func onSelect(with model: ACColorPickerModel) {
        model.gradientConstantPublisher.send(constant)
    }
    public func pasteboardWriter() -> NSPasteboardWriting? {
        constant.pasteboardRefWriting(for: .bpConstant)
    }
    
    init(_ constant: BPConstant, document: AxDocument) {
        self.constant = constant
        self.document = document
    }
}

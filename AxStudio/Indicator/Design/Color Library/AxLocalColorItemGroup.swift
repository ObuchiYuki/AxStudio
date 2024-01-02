//
//  AxLocalColorItemGroup.swift
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

extension AxDocument {
    public var documentColorLibrary: ACColorItemLibrary {
        session.localCache("colorItemLibrary", make: ACColorItemLibrary() => {
            $0.register(AxLocalColorItemGroup(self))
            $0.register(ACStandardColorItemGroup.shared)
        })
    }
}

final public class AxLocalColorItemGroup: ACColorItemGroup {
    public let canAddItem: Bool = true
    public let canMoveItem: Bool = true
    public let canDeattch: Bool = true
    public let name: String = "This Document"
    
    @ObservableProperty private var items = [ACColorItem]()
    
    public func itemsp(for option: ACColorWell.Options) -> AnyPublisher<[ACColorItem], Never> {
        document.rootNode.constantStorage.$colors
            .map{[unowned self] colors in
                var items = [ACColorItem]()
                if option.contains(.color) { items.append(AxLocalColorItem(accent: document.rootNode.constantStorage.accentColor, document: document)) }
                items.append(contentsOf: colors.filter{ option.match(to: $0.fillType) }.compactMap{ $0.colorItem(document) })
                return items
            }
            .peek{[unowned self] in self.items = $0 }
            .eraseToAnyPublisher()
    }
    
    public func selectedItemp(_ model: ACColorPickerModel) -> AnyPublisher<ACColorItem?, Never> {
        $items.combineLatest(model.$linkingConstant)
            .map{ items, constant in
                items.first(where: { $0.uconstant === constant })
            }
            .eraseToAnyPublisher()        
    }
    
    public func onMoveItem(_ pasteboard: NSPasteboard, to index: Int) -> Bool {
        guard let constant = pasteboard.getNodeRefs(for: .bpConstant, session: document.session)?.first else { return false }
        document.execute(AxMoveColorConstantCommand(constant, index - 1))
        return true
    }
    public func onAddColor(_ color: DKColor, name: String, model: ACColorPickerModel) throws {
        let constant = try AxMakeConstant.color(color, name: name, document: document)
        model.colorConstantPublisher.send(constant)
    }
    public func onAddGradient(_ gradient: DKGradient, name: String, model: ACColorPickerModel) throws {
        let constant = try AxMakeConstant.gradient(gradient, name: name, document: document)
        model.gradientConstantPublisher.send(constant)
    }
    
    let document: AxDocument
    
    init(_ document: AxDocument) { self.document = document }
}

extension ACColorItem {
    fileprivate var uconstant: BPConstant? {
        if let item = self as? AxLocalColorItem { return item.constant }
        if let item = self as? AxLocalGradientItem { return item.constant }
        return nil
    }
}

extension BPConstant {
    fileprivate var fillType: DKFillType? {
        if self.value is BPColor { return .color }
        if self.value is BPGradient { return .gradient }
        return nil
    }
    
    fileprivate func colorItem(_ document: AxDocument) -> ACColorItem? {
        if self.value is BPColor { return AxLocalColorItem(self, document: document) }
        if self.value is BPGradient { return AxLocalGradientItem(self, document: document) }
        return nil
    }
}
extension ACColorWell.Options {
    fileprivate func match(to fillType: DKFillType?) -> Bool {
        switch fillType {
        case .none: return false
        case .color: return self.contains(.color)
        case .gradient: return self.contains(.gradient)
        }
    }
}

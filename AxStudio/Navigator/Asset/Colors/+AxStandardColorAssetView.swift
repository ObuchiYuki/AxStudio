//
//  +AxStandardColorAssetView.swift
//  AxStudio
//
//  Created by yuki on 2021/12/02.
//

import SwiftEx
import BluePrintKit
import AxComponents
import Combine
import DesignKit

struct AxStandardColorAsset: AxColorAssetItem {
    let colorOption: ACColorWell.Options? = nil
    let canRename: Bool = false
    let canRemove: Bool = false
    
    var assetType: AxColorAssetType { .color }
    
    var namep: AnyPublisher<String, Never> { .just(name) }
    var colorp: AnyPublisher<BPColor, Never> { .just(color) }
    
    private let color: BPColor
    private let name: String
    
    func pasteboardWriter() -> NSPasteboardWriting? {
        color.pasteboardWriter(forType: .bpColor)
    }
    
    init(color: BPColor, name: String) {
        self.name = name
        self.color = color
    }
}

struct AxStandardGradientAsset: AxColorAssetItem {
    let colorOption: ACColorWell.Options? = nil
    let canRename: Bool = false
    let canRemove: Bool = false
    
    var assetType: AxColorAssetType { .gradient }
    
    var namep: AnyPublisher<String, Never> { .just(name) }
    var gradientp: AnyPublisher<DKGradient, Never> { .just(gradient) }
    
    private let name: String
    private let gradient: DKGradient
    
    func pasteboardWriter() -> NSPasteboardWriting? {
        gradient.pasteboardWriter(forType: .bpGradient)
    }
    
    init(gradient: DKGradient, name: String) {
        self.name = name
        self.gradient = gradient
    }
}
 
final class AxStandardColorAssetViewController: AxColorAssetListViewController {
    override func chainObjectDidLoad() {
        self.assets = [
            AxStandardColorAsset(color: .white, name: "White"),
            AxStandardColorAsset(color: .black, name: "Black"),
            
            AxStandardColorAsset(color: .red, name: "Red"),
            AxStandardColorAsset(color: .orange, name: "Orange"),
            AxStandardColorAsset(color: .yellow, name: "Yellow"),
            AxStandardColorAsset(color: .green, name: "Green"),
            AxStandardColorAsset(color: .teal, name: "Teal"),
            AxStandardColorAsset(color: .blue, name: "Blue"),
            AxStandardColorAsset(color: .indigo, name: "Indigo"),
            AxStandardColorAsset(color: .purple, name: "Purple"),
            AxStandardColorAsset(color: .pink, name: "Pink"),
            
            AxStandardColorAsset(color: .gray1, name: "Gray 1"),
            AxStandardColorAsset(color: .gray2, name: "Gray 2"),
            AxStandardColorAsset(color: .gray3, name: "Gray 3"),
            AxStandardColorAsset(color: .gray4, name: "Gray 4"),
            AxStandardColorAsset(color: .gray5, name: "Gray 5"),
            AxStandardColorAsset(color: .gray6, name: "Gray 6"),
            
            AxStandardColorAsset(color: .primary, name: "Primary"),
            AxStandardColorAsset(color: .secondary, name: "Secondary"),
            AxStandardColorAsset(color: .tertiary, name: "Tertiary"),
            AxStandardColorAsset(color: .quaternary, name: "Quaternary"),
            AxStandardColorAsset(color: .placeholder, name: "Placeholder"),
            AxStandardColorAsset(color: .link, name: "Link"),
            
            AxStandardColorAsset(color: .separator, name: "Separator"),
            
            AxStandardGradientAsset(gradient: .shadow, name: "Shadow"),
            AxStandardGradientAsset(gradient: .bluesky, name: "Blue Sky"),
            AxStandardGradientAsset(gradient: .neon, name: "Neon"),
            AxStandardGradientAsset(gradient: .metal, name: "Metal"),
            AxStandardGradientAsset(gradient: .rainbow, name: "Rainbow"),
        ]
    }
}

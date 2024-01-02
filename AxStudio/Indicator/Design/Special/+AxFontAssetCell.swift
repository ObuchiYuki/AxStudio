//
//  AxFontAssetCell+.swift
//  AxStudio
//
//  Created by yuki on 2021/12/28.
//

import AxComponents
import AxDocument
import DesignKit
import SwiftEx
import AppKit
import AxCommand
import BluePrintKit

final class AxFontAssetCellController: NSViewController {
    private let cell = AxFontAssetCell()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        // MARK: - Input -
        let layers = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? DKFontProviderLayerType } }
        let likingAsset = layers.switchToLatest{ $0.map{ $0.fontProvider.$linkingAsset.map{ $0?.value } }.combineLatest }
            .map{ $0.mixture(nil, { $0 === $1 }) }
        let currentStorage = layers.switchToLatest{ $0.map{ $0.fontProvider.$storage }.combineLatest }
            .map{ $0.mixture(.font(.systemDefault)) }
        let isModified = currentStorage.combineLatest(likingAsset)
            .map{ $0.combine($1).map{ storage, asset in asset.map{ storage == .asset($0.ref) } ?? true }.reduce(mixed: true) }.map{ !$0 }
        let isAsset = currentStorage.map{ $0.map{ $0.isAsset } == .identical(true) }
        
        likingAsset
            .sink{[unowned self] in cell.fontAssetWell.linkingAsset = $0 }.store(in: &objectBag)
        currentStorage
            .sink{[unowned self] in cell.fontAssetWell.selectedFont = $0.map{ $0.font } }.store(in: &objectBag)
        isModified
            .sink{[unowned self] in cell.fontAssetWell.isModified = $0; cell.updateButton.isEnabled = $0 }.store(in: &objectBag)
        likingAsset.map{ asset -> Bool in if case let .identical(asset) = asset { return asset != nil } else { return true } }
            .sink{[unowned self] in cell.deatchButton.isEnabled = $0 }.store(in: &objectBag)
        isAsset.combineLatest(currentStorage).map{ !$0 && !$1.isMixed }
            .sink{[unowned self] in cell.addButton.isEnabled = $0 }.store(in: &objectBag)
        
        // MARK: - Output -
        cell.fontAssetWell.fontPublisher
            .sink{[unowned self] in document.execute(AxFontProviderBecomeFontCommand($0)) }.store(in: &objectBag)
        cell.fontAssetWell.assetPublisher
            .sink{[unowned self] in document.execute(AxFontProviderBecomeAssetCommand($0)) }.store(in: &objectBag)
        cell.addButton.actionPublisher
            .sink{[unowned self] in createAsset() }.store(in: &objectBag)
        cell.updateButton.actionPublisher
            .sink{[unowned self] in document.execute(AxFontProviderUpdateAssetCommand()) }.store(in: &objectBag)
        cell.deatchButton.actionPublisher
            .sink{[unowned self] in document.execute(AxFontProviderDetachCommand()) }.store(in: &objectBag)
    }
    
    public func createAsset() {
        guard let window = self.view.window else { return }
        
        let alert = NSAlert()
        let textField = ACTextField_(frame: NSRect(size: [225, 21]))
        textField.snp.makeConstraints{ make in
            make.width.equalTo(225)
        }
        textField.placeholder = "Text Style Name"
        
        let okButton = alert.addButton(withTitle: "OK")
        alert.accessoryView = textField
        alert.messageText = "Create new Text Style"
        alert.addButton(withTitle: "Cancel")
        okButton.isEnabled = false
        var string = ""
        textField.changePublisher
            .sink{
                string = $0
                okButton.isEnabled = !$0.isEmpty
            }
            .store(in: &textField.objectBag)
        alert.beginSheetModal(for: window) { res in
            if res == .alertFirstButtonReturn {
                self.document.execute(AxMakeFontAssetCommand(string))
            }
        }
        DispatchQueue.main.async{
            textField.window?.makeFirstResponder(textField.textField)
        }
    }
}

final private class AxFontAssetCell: ACGridView {
    let fontAssetWell = ACFontAssetWell.autoconnect()
    let addButton = ACTitleButton__(title: "Create", image: R.Image.lightAddBtton)
    let updateButton = ACTitleButton__(title: "Update", image: R.Image.lightReload)
    let deatchButton = ACTitleButton__(title: "Detach", image: R.Image.detachIcon)

    override func onAwake() {
        self.addItem3(fontAssetWell, row: 0, column: 0, length: 3)
        self.addItem3(addButton, row: 1.7, column: 0)
        self.addItem3(updateButton, row: 1.7, column: 1)
        self.addItem3(deatchButton, row: 1.7, column: 2)
    }
}

extension DKFontProvider.Storage {
    fileprivate var isAsset: Bool {
        if case .asset = self { return true } else { return false }
    }
}

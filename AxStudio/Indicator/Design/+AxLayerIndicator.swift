//
//  AxDesignIndicatorViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/09/30.
//

import AppKit
import DesignKit
import AxComponents
import BluePrintKit
import STDComponents
import SwiftEx
import AppKit

final class AxDesignIndicatorViewController: ACStackViewController_ {
    private let geometoryCell = AxGeometryCellController()
    
    private let layoutHeaderCell = ACStackViewFoldHeaderController(title: "Layout")
    private let sizeCell = AxSizeCellController()
    private let positionCell = AxPositionCellController()
        
    private let masterLayoutHeaderCell = ACStackViewFoldHeaderController(title: IS_DEBUG ? "Layout (Master)" : "Layout")
    private let masterLayoutCell = AxMasterLayoutCellController()
    
    private let screenHeaderCell = ACStackViewFoldHeaderController(title: "Screen")
    private let deviceCell = AxDeviceCellController()
    
    private let cornerRadiusHeaderCell = ACStackViewFoldHeaderController(title: "Corner")
    private let cornerRadiusCell = AxCornerRadiusCellController()
    
    private let groupHeaderCell = ACStackViewFoldHeaderController(title: "Group")
    private let groupCell = AxGroupCellController()
    
    private let stackHeaderCell = ACStackViewFoldHeaderController(title: "Stack")
    private let stackCell = AxStackCellController()
    
    private let stackSpacerHeaderCell = ACStackViewFoldHeaderController(title: "Spacer")
    private let stackSpacerCell = AxStackSpacerCellController()
    
    private let ellipseHeaderCell = ACStackViewFoldHeaderController(title: "Ellipse")
    private let ellipseCell = AxEllipseCellController()
    
    private let iconHeaderCell = ACStackViewFoldHeaderController(title: "Icon")
    private let iconCell = AxIconCellController()
    
    private let sliderHeaderCell = ACStackViewFoldHeaderController(title: "Slider")
    private let sliderCell = AxSliderCellController()
    
    private let switchHeaderCell = ACStackViewFoldHeaderController(title: "Swicth")
    private let switchCell = AxSwitchCellController()
    
    private let buttonHeaderCell = ACStackViewFoldHeaderController(title: "Button")
    private let buttonCell = AxButtonCellController()
    
    private let textInputHeaderCell = ACStackViewFoldHeaderController(title: "Text Input")
    private let textInputFontCell = AxFontAssetCellController()
    private let textInputCell = AxTextInputCellController()
    
    private let segmentHeaderCell = AxSegmentedControlHeaderCellController(title: "Segmented Control")
    private let segmentCell = AxSegmentedControlCellController()
    private let segmentListHeaderCell = ACStackViewHeaderCellController_(title: "Items".locarized(), style: .small)
    private let segmentListCell = AxSegmentedItemListCellController()
    
    private let tableHeaderCell = ACStackViewFoldHeaderController(title: "Table")
    private let tableCell = AxTableLinkCellController()
    
    private let listHeaderCell = ACStackViewFoldHeaderController(title: "List")
    private let listCell = AxListCellController()
    
    private let textHeaderCell = ACStackViewFoldHeaderController(title: "Text")
    private let textAssetCell = AxFontAssetCellController()
    private let textCell = AxTextCellController()
    
    private let imageHeaderCell = ACStackViewFoldHeaderController(title: "Image".locarized())
    private let imageCell = AxImageCellController()
    
    private let instanceHeaderCell = ACStackViewFoldHeaderController(title: "Instance".locarized())
    private let instanceCell = AxInstanceCellController()
    
    private let styleHeaderCell = ACStackViewFoldHeaderController(title: "Style".locarized(), defaultState: true)
    private let opacityCell = AxOpacityCellController()
    
    private let fillHeaderCell = ACStackViewHeaderCellController_(title: "Fill".locarized(), style: .small)
    private let fillCell = AxStyleFillCellController()
    
    private let borderHeaderCell = ACStackViewHeaderCellController_(title: "Border".locarized(), style: .small)
    private let borderCell = AxStyleBorderCellController()
    
    private let shadowHeaderCell = ACStackViewHeaderCellController_(title: "Shadow".locarized(), style: .small)
    private let shadowCell = AxStyleShadowCellController()
    
    private let solidFillHeaderCell = ACStackViewHeaderCellController_(title: "Tint", style: .small)
    private let solidFillCell = AxStyleSolidFillCellController()
    
    private let componentActionHeaderCell = ACComponentActionHeaderController(title: "Action")
    private let componentActionListCell = AxComponentActionListCellController()
    
    private let statesHeaderCell = ACStateHeaderController(title: "State")
    private let stateListCell = AxStateListCellController()
    private let stateInfoCell = AxStateInfoCellController()
        
    private let actionHeaderCell = AxActionHeaderController(title: "Actions")
    private let actionListCell = AxActionListCellController()
    
    private let debugHeaderCell = ACStackViewFoldHeaderController(title: "Debug")
    private let debugCell = AxDesignDebugCellController()
    private let debugLayoutCell = AxDebugLayoutCellController()
    
    private lazy var selector = ACStackViewCellSelector_<[DKLayer]>(self)
    
    override func chainObjectDidLoad() {
        let parentChange = document.$selectedLayers.switchToLatest{ $0.map{ $0.$parent }.combineLatest }
        let states = document.$selectedLayers.map{ $0.singleOrNil()?.statesp }.involveSwitchToLatest()
        let actions = document.$selectedLayers.map{ $0.singleOrNil()?.viewModelLayer?.viewModel.$actions }.involveSwitchToLatest()
        let cactions = document.$selectedLayers.map{ $0.singleOrNil()?.componentLayer?.$componentActions }.involveSwitchToLatest()
        
        let reload = document.$selectedLayers.touch(parentChange, document.$selectedState, document.$selectedAction).touch(states, actions, cactions)
            .grouping(by: document.executeSession)
        
        reload
            .sink{[unowned self] in self.selector.reloadData(with: $0) }.store(in: &objectBag)
        reload.grouping(by: document.selectionSession)
            .sink{[unowned self] _ in self.view.window?.recalculateKeyViewLoop() }.store(in: &objectBag)
    }
    
    private func shouldShowLayoutIndicator(_ layers: [DKLayer]) -> Bool {
        if layers.contains(where: { $0 is DKMasterLayer }) { return false }
        return layers.unmasterNonEmptyAllSatisfy{ $0.userCanUpdateLayout }
    }
    private func shouldShowPositionIndicator(_ layers: [DKLayer]) -> Bool {
        layers.allSatisfy{ $0.parent?.value is DKGroup } && layers.unmasterNonEmptyAllSatisfy{ $0.userCanUpdateLayout }
    }
    private func shouldShowSizeIndicator(_ layers: [DKLayer]) -> Bool {
        true
    }
    
    override func viewDidLoad() {
        self.stackView.edgeInsets = .zero
        self.stackView.edgeInsets.top = 8
        self.stackView.edgeInsets.bottom = 12

        self.selector.register([geometoryCell]) { layers in
            true
        }
        self.selector.registerFoldable(
            layoutHeaderCell, [
                .group([sizeCell], shouldShowSizeIndicator),
                .group([positionCell], shouldShowPositionIndicator)
            ], shouldShowLayoutIndicator
        )
        self.selector.registerFoldable(masterLayoutHeaderCell, [masterLayoutCell]) { layers in
            layers.count == 1 && layers.first is DKMasterLayer
        }        
        self.selector.registerFoldable(screenHeaderCell, [deviceCell]) { layers in
            layers.allSatisfy{ $0 is DKScreen }
        }
        self.selector.registerFoldable(imageHeaderCell, [imageCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKImageLayer }
        }
        self.selector.registerFoldable(cornerRadiusHeaderCell, [cornerRadiusCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKCornerRadiusLayerType }
        }
        self.selector.registerFoldable(iconHeaderCell, [iconCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKIconLayer }
        }
        self.selector.registerFoldable(switchHeaderCell, [switchCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is STDSwitch }
        }
        self.selector.registerFoldable(textInputHeaderCell, [textInputFontCell, .separator(padding: .rightPin), textInputCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is STDTextInput }
        }
        self.selector.registerFoldable(sliderHeaderCell, [sliderCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is STDSlider }
        }
        self.selector.registerFoldable(buttonHeaderCell, [buttonCell]) { layers in
            layers.nonEmptyAllSatisfy{ $0 is STDButton }
        }
        self.selector.registerFoldable(segmentHeaderCell, [
            .group([segmentCell]),
            .group([.separator(padding: .rightPin), segmentListHeaderCell, segmentListCell]) { $0.count == 1 }
        ]) { layers in
            layers.nonEmptyAllSatisfy{ $0 is STDSegmentedControl }
        }
        self.selector.registerFoldable(tableHeaderCell, [tableCell]) { layers in
            layers.count == 1 && layers.first?.entity() is DKTableLinkLayer
        }
        self.selector.registerFoldable(listHeaderCell, [listCell]) { layers in
            layers.count == 1 && layers.first?.entity() is STDList
        }
        self.selector.registerFoldable(ellipseHeaderCell, [ellipseCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKEllipse }
        }
        self.selector.registerFoldable(textHeaderCell, [textAssetCell, .separator(padding: .rightPin), textCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKTextLayer }
        }
        self.selector.registerFoldable(stackHeaderCell, [stackCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKStackLayer }
        }
        self.selector.registerFoldable(stackSpacerHeaderCell, [stackSpacerCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKStackSpacer }
        }
        self.selector.registerFoldable(groupHeaderCell, [groupCell]) { layers in
            layers.unmasterNonEmptyAllSatisfy{ $0 is DKGroup }
        }
        self.selector.registerFoldable(instanceHeaderCell, [instanceCell]) { layers in
            layers.count == 1 && layers.unmasterNonEmptyAllSatisfy{ $0 is DKInstanceLayer }
        }

        func shouldShowShadow(_ layers: [DKLayer]) -> Bool {
            layers.allSatisfy{ !($0 is DKScreen) } && layers.unmasterNonEmptyAllSatisfy{ $0 is DKStyleShadowLayerType }
        }
        func shoulwShowTint(_ layers: [DKLayer]) -> Bool {
            layers.allSatisfy{ !($0 is DKFontProviderLayerType) } && layers.unmasterNonEmptyAllSatisfy{ $0 is DKStyleSolidFillLayerType }
        }
        self.selector.registerFoldable(styleHeaderCell, [
            .group([opacityCell]) { layers in true },
            .group([fillHeaderCell, fillCell]) { layers in layers.unmasterNonEmptyAllSatisfy{ $0 is DKStyleFillLayerType } },
            .group([borderHeaderCell, borderCell]) { layers in layers.unmasterNonEmptyAllSatisfy{ $0 is DKStyleBorderLayerType } },
            .group([shadowHeaderCell, shadowCell], shouldShowShadow),
            .group([solidFillHeaderCell, solidFillCell], shoulwShowTint),
        ]) { layers in true }
        
        self.selector.registerFoldable(statesHeaderCell, [
            .group([stateListCell]) { layers in !(layers.first?.states?.isEmpty ?? true) },
            .group([.separator(padding: .inset), stateInfoCell]) { _ in self.document.selectedState != nil },
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.viewModelLayer != nil || $0.componentLayer != nil })
        }
        self.selector.registerFoldable(componentActionHeaderCell, [
            .group([componentActionListCell]) { layers in !(layers.first?.componentLayer?.componentActions.isEmpty ?? true) }
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.componentLayer != nil })
        }
        self.selector.registerFoldable(actionHeaderCell, [
            .group([actionListCell]) { layers in !(layers.first?.viewModelLayer?.viewModel.actions.isEmpty ?? true) }
        ]) { layers in
            layers.count == 1 && layers.contains(where: { $0.viewModelLayer != nil })
        }
        
        #if DEBUG
        self.selector.registerFoldable(debugHeaderCell, [debugCell, debugLayoutCell]) {_ in
            DebugSettings.showDebugCell
        }
        #endif
        
        self.selector.reloadData(with: document.selectedLayers)

        DispatchQueue.main.async {
            self.view.window?.recalculateKeyViewLoop()
        }
    }
}

extension DKLayer {
    fileprivate var showTintIndicator: Bool {
        (self as? DKStyleSolidFillLayerType)?.shouldShowTintIndicator ?? false
    }
}

extension Array {
    @inlinable public func nonEmptyAllSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        !isEmpty && allSatisfy(predicate)
    }
}

extension Array where Element: DKLayer {
    @inlinable public func unmasterNonEmptyAllSatisfy(_ predicate: (DKLayer) -> Bool) -> Bool {
        if isEmpty { return false }
        
        for layer in self {
            if !predicate(layer.entity()) { return false }
        }
        
        return true
    }
}

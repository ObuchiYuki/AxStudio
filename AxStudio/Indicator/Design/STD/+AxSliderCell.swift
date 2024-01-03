//
//  +AxSliderCell.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import SwiftEx
import AppKit
import AxComponents
import STDComponents
import AxCommand
import DesignKit
import BluePrintKit

final class AxSliderCellController: NSViewController {
    private let cell = AxSliderCell()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        let sliders = document.selectedUnmasteredLayersp.compactMap{ $0.compactAllSatisfy{ $0 as? STDSlider } }
        let sliderValue = sliders.dynamicProperty(\.$value, document: document).removeDuplicates()
        let minValue = sliders.switchToLatest{ $0.map{ $0.$minValue }.combineLatest }.map{ $0.mixture(0) }
        let maxValue = sliders.switchToLatest{ $0.map{ $0.$maxValue }.combineLatest }.map{ $0.mixture(0) }
        
        sliderValue.combineLatest(minValue, maxValue).map{[unowned self] in self.inputSliderValue($0, minValue: $1, maxValue: $2) }
            .sink{[unowned self] in cell.valueSlider.setDynamicState($0) }.store(in: &objectBag)
        sliderValue
            .sink{[unowned self] in cell.valueField.setDynamicState($0) }.store(in: &objectBag)
        sliderValue
            .sink{[unowned self] in cell.valueTip.setDynamicState($0) }.store(in: &objectBag)
        minValue
            .sink{[unowned self] in cell.minValueField.fieldValue = $0.map{ $0 } }.store(in: &objectBag)
        maxValue
            .sink{[unowned self] in cell.maxValueField.fieldValue = $0.map{ $0 } }.store(in: &objectBag)
        
        cell.valueSlider.valuePublisher
            .sink{[unowned self] in self.outputSliderValue($0) }.store(in: &objectBag)
        cell.valueSlider.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDSlider.value)) }.store(in: &objectBag)
        
        cell.valueField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxSliderValueCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.valueField.statePublisher
            .sink{[unowned self] in document.execute(AxLinkToStateCommand($0, \STDSlider.value)) }.store(in: &objectBag)
        cell.valueTip.commandPublisher
            .sink{[unowned self] in document.execute(AxDynamicLayerPropertyCommand($0, "value", \STDSlider.value)) }.store(in: &objectBag)
        cell.minValueField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxSliderMinValueCommand.fromPhase($0)) }.store(in: &objectBag)
        cell.maxValueField.phasePublisher
            .sink{[unowned self] in document.session.broadcast(AxSliderMaxValueCommand.fromPhase($0)) }.store(in: &objectBag)
    }
    
    private func outputSliderValue(_ value: Phase<CGFloat>) {
        let sliders = document.selectedUnmasteredLayers.compactMap{ $0 as? STDSlider }
        let minValue = sliders.map{ $0.minValue }.mixture(0)
        let maxValue = sliders.map{ $0.maxValue }.mixture(0)
        guard case let .identical((min, max)) = minValue.combine(maxValue) else { return __warn_ifDebug_beep_otherwise() }
                
        let nvalue = value.map{ $0 * (max - min) + min }
        
        document.session.broadcast(AxSliderValueCommand.fromPhase(nvalue.map{ .to($0) }))
    }
    private func inputSliderValue(_ state: ACDynamicState<BPFloat?>, minValue: Mixture<CGFloat>, maxValue: Mixture<CGFloat>) -> ACDynamicState<BPFloat?> {
        let minmax = minValue.combine(maxValue)
        switch minmax {
        case let .identical((min, max)): return state.map{
            $0.map{ BPFloat(($0.value - min) / (max - min)) }
        }
        case .mixed: return .init(stateType: .uneditable, value: .mixed)
        }
    }
}

final private class AxSliderCell: ACGridView {
    let valueTip = ACDynamicTip.autoconnect(.float, dynamic: false)
    
    let valueSlider = ACSlider_(stateDrop: true)
    let valueField = ACNumberField_(stateDrop: true)
    let minValueField = ACNumberField_().stepper()
    let maxValueField = ACNumberField_().stepper()
    
    override func onAwake() {
        self.addItem3(valueSlider, row: 0, column: 0, length: 2, decorator: valueTip)
        self.addItem3(valueField, row: 0, column: 2)
        
        self.addItem3(ACAreaLabel_(title: "Range"), row: 1, column: 0)
        self.addItem3(minValueField, row: 1, column: 1)
        self.addItem3(ACControlLabel("Min"), row: 1.9, column: 1)
        self.addItem3(maxValueField, row: 1, column: 2)
        self.addItem3(ACControlLabel("Max"), row: 1.9, column: 2)
        self.valueField.arrowKeyStepValue = 0.1
        
        self.gridHeight = 2.5
    }
}

//
//  DesignKit+DefaultItem.swift
//  AxStudio
//
//  Created by yuki on 2021/11/14.
//

import DesignKit
import STDComponents
import AxModelCore
import BluePrintKit

extension STDButton {
    enum Default {
        public static let text = AxModelSession.freestanding.execute{
            try! STDButton.make(on: .freestanding) => { (button: STDButton) in
                button.name = "Button"
                
                let titleLayer = try! DKTextLayer.make(on: .freestanding) => { (titleLayer: DKTextLayer) in
                    titleLayer.name = "Text"
                    titleLayer.constraints.widthType = .auto
                    titleLayer.constraints.heightType = .auto
                    titleLayer.style.fill.color = .constant(AxModelRef(.accentColorConstantID))
                    titleLayer.string = .static("Button")
                }
                button.stackLayer.prebuildAddSublayer(titleLayer)
                
                button.stackLayer.alignment = .mid
                button.stackLayer.distribution = .mid
                button.stackLayer.orientation = .horizontal
                button.stackLayer.constraints.widthType = .auto
                button.stackLayer.constraints.heightType = .auto
            }
        }        
    }
//    
//    public static func solid() -> STDButton {
//        let button = STDButton()
//        button.name = "Solid Button"
//        
//        let titleLayer = DKTextLayer()
//        titleLayer.name = "Text"
//        titleLayer.constraints.widthType = .auto
//        titleLayer.constraints.heightType = .auto
//        titleLayer.style.fill.color = .static(.white)
//        titleLayer.string = .static("Button")
//        button.stackLayer.prebuildAddSublayer(titleLayer)
//        
//        button.stackLayer.cornerRadius.cornerType = .capsule
//        button.stackLayer.alignment = .mid
//        button.stackLayer.distribution = .mid
//        button.stackLayer.padding = .init(x: 0, y: 8)
//        button.stackLayer.orientation = .horizontal
//        button.stackLayer.constraints.widthType = .auto
//        button.stackLayer.constraints.heightType = .auto
//        button.stackLayer.style.fill.isEnabled = true
//        button.stackLayer.style.fill.color = .constant(AxModelRef(.accentColorConstantID, session: .prebuild))
//        
//        return button
//    }
//    
//    public static func bordered() -> STDButton {
//        let button = STDButton()
//        button.name = "Bordered Button"
//        
//        let titleLayer = DKTextLayer()
//        titleLayer.name = "Text"
//        titleLayer.constraints.widthType = .auto
//        titleLayer.constraints.heightType = .auto
//        titleLayer.style.fill.color = .static(.teal)
//        titleLayer.string = .static("Button")
//        button.stackLayer.prebuildAddSublayer(titleLayer)
//        
//        button.stackLayer.cornerRadius.cornerType = .fixedSize
//        button.stackLayer.cornerRadius.radius = .static(6)
//        button.stackLayer.alignment = .mid
//        button.stackLayer.distribution = .mid
//        button.stackLayer.padding = .init(x: 0, y: 8)
//        button.stackLayer.orientation = .horizontal
//        button.stackLayer.constraints.widthType = .auto
//        button.stackLayer.constraints.heightType = .auto
//        button.stackLayer.style.border.isEnabled = true
//        button.stackLayer.style.border.width = .static(1)
//        button.stackLayer.style.border.color = .static(.teal)
//        
//        return button
//    }
//    
//    public static func gradient() -> STDButton {
//        let button = STDButton()
//        button.name = "Gradient Button"
//        
//        let titleLayer = DKTextLayer()
//        titleLayer.name = "Text"
//        titleLayer.constraints.widthType = .auto
//        titleLayer.constraints.heightType = .auto
//        titleLayer.style.fill.color = .static(.white)
//        titleLayer.string = .static("Button")
//        button.stackLayer.prebuildAddSublayer(titleLayer)
//        
//        button.stackLayer.cornerRadius.cornerType = .capsule
//        button.stackLayer.alignment = .mid
//        button.stackLayer.distribution = .mid
//        button.stackLayer.padding = .init(x: 0, y: 8)
//        button.stackLayer.orientation = .horizontal
//        button.stackLayer.constraints.widthType = .auto
//        button.stackLayer.constraints.heightType = .auto
//        button.stackLayer.style.fill.isEnabled = true
//        button.stackLayer.style.fill.type = .gradient
//        button.stackLayer.style.fill.gradient = .static(BPGradient.neon.withFrom([0, 0.5]).withTo([1, 0.5]))
//        
//        return button
//    }
//    
//    public static func icon() -> STDButton {
//        let button = STDButton()
//        button.constraints.widthValue = .static(32)
//        button.constraints.heightValue = .static(32)
//        button.name = "Icon Button"
//        
//        let iconLayer = DKIconLayer()
//        iconLayer.name = "Icon"
//        iconLayer.icon = .static(.heartCircleFill)
//        iconLayer.constraints.widthValue = .static(32)
//        iconLayer.constraints.heightValue = .static(32)
//        iconLayer.color = .static(.pink)
//        button.stackLayer.prebuildAddSublayer(iconLayer)
//        
//        button.stackLayer.cornerRadius.cornerType = .capsule
//        button.stackLayer.alignment = .mid
//        button.stackLayer.distribution = .mid
//        button.stackLayer.orientation = .horizontal
//        button.stackLayer.constraints.widthType = .auto
//        button.stackLayer.constraints.heightType = .auto
//        
//        return button
//    }
//    
//    public static func iconAndTitle() -> STDButton {
//        let button = STDButton()
//        button.name = "Icon and Title Button"
//        
//        let titleLayer = DKTextLayer()
//        titleLayer.name = "Text"
//        titleLayer.constraints.widthType = .auto
//        titleLayer.constraints.heightType = .auto
//        titleLayer.string = .static("Button")
//        titleLayer.style.fill.color = .static(.white)
//        button.stackLayer.prebuildAddSublayer(titleLayer)
//        
//        let iconLayer = DKIconLayer()
//        iconLayer.icon = .static(.mic)
//        iconLayer.constraints.widthValue = .static(20)
//        iconLayer.constraints.heightValue = .static(20)
//        iconLayer.color = .static(.white)
//        button.stackLayer.prebuildAddSublayer(iconLayer)
//        
//        button.stackLayer.cornerRadius.cornerType = .fixedSize
//        button.stackLayer.cornerRadius.radius = .static(6)
//        button.stackLayer.alignment = .mid
//        button.stackLayer.distribution = .mid
//        button.stackLayer.orientation = .horizontal
//        button.stackLayer.constraints.widthType = .auto
//        button.stackLayer.constraints.heightType = .auto
//        button.stackLayer.padding = .init(x: 0, y: 8)
//        button.stackLayer.style.fill.isEnabled = true
//        button.stackLayer.style.fill.type = .gradient
//        button.stackLayer.style.fill.gradient = .static(BPGradient.bluesky.withFrom([0, 0.5]).withTo([1, 0.5]))
//        
//        return button
//    }
}

//extension DKStackLayer {
//    
//    static func listStack() -> DKStackLayer {
//        func makeCell(_ name: String, icon: BPIcon) -> DKStackLayer {
//            let cell = DKStackLayer()
//            cell.orientation = .horizontal
//            cell.constraints.widthType = .auto
//            cell.constraints.heightType = .auto
//            cell.fill.isEnabled = true
//            cell.fill.color = .static(.white)
//            cell.padding = .init(x: 8, y: 4)
//            
//            let label = DKTextLayer()
//            label.string = .static(BPString(name))
//            label.constraints.widthType = .auto
//            label.constraints.heightType = .auto
//            
//            let spacer = DKStackSpacer()
//            
//            let iconLayer = DKIconLayer()
//            iconLayer.icon = .static(icon)
//            iconLayer.constraints.widthValue = .static(15)
//            iconLayer.constraints.heightValue = .static(15)
//            
//            cell.prebuildAddSublayer(iconLayer)
//            cell.prebuildAddSublayer(spacer)
//            cell.prebuildAddSublayer(label)
//            
//            return cell
//        }
//        
//        let listLayer = DKStackLayer()
//        listLayer.name = "List"
//        listLayer.constraints.widthType = .auto
//        listLayer.constraints.heightType = .auto
//        
//        listLayer.prebuildAddSublayer(makeCell("Alice", icon: .heart))
//        listLayer.prebuildAddSublayer(makeCell("Bob", icon: .star))
//        listLayer.prebuildAddSublayer(makeCell("Cathy", icon: .bell))
//        return listLayer
//    }
//    
//    static func horizontalStack() -> DKStackLayer {
//        let stackLayer = DKStackLayer()
//        stackLayer.orientation = .horizontal
//        stackLayer.name = "HStack"
//        
//        let layer1 = DKRectangle()
//        layer1.constraints.widthType = .auto
//        layer1.constraints.heightType = .auto
//        layer1.style.fill.color = .static(.orange)
//        
//        let layer2 = DKRectangle()
//        layer2.constraints.widthType = .auto
//        layer2.constraints.heightType = .auto
//        layer2.style.fill.color = .static(.orange)
//        
//        stackLayer.prebuildAddSublayer(layer1)
//        stackLayer.prebuildAddSublayer(layer2)
//        
//        return stackLayer
//    }
//    
//    static func verticalStack() -> DKStackLayer {
//        let stackLayer = DKStackLayer()
//        stackLayer.orientation = .vertical
//        stackLayer.name = "VStack"
//        
//        let layer1 = DKRectangle()
//        layer1.constraints.widthType = .auto
//        layer1.constraints.heightType = .auto
//        layer1.style.fill.color = .static(.orange)
//        
//        let layer2 = DKRectangle()
//        layer2.constraints.widthType = .auto
//        layer2.constraints.heightType = .auto
//        layer2.style.fill.color = .static(.orange)
//        
//        stackLayer.prebuildAddSublayer(layer1)
//        stackLayer.prebuildAddSublayer(layer2)
//        
//        return stackLayer
//    }
//}
//

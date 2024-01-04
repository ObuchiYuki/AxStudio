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

extension STDSwitch {
    public static let `default` = try! AxModelSession.freestanding.execute {
        try STDSwitch.make(on: .freestanding)
    }
}

extension STDTextInput {
    public static let `default` = try! AxModelSession.freestanding.execute {
        try STDTextInput.make(on: .freestanding)
    }
}

extension STDSegmentedControl {
    public static let `default` = try! AxModelSession.freestanding.execute {
        try STDSegmentedControl.make(on: .freestanding)
    }
}


extension DKIconLayer {
    public static let `default` = try! AxModelSession.freestanding.execute {
        try DKIconLayer.make(on: .freestanding)
    }
}

extension STDSlider {
    public static let `default` = try! AxModelSession.freestanding.execute {
        try STDSlider.make(on: .freestanding)
    }
}

extension STDButton {
    public static let text = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.name = "Button"
        
        let titleLayer = try! DKTextLayer.make(on: .freestanding)
        titleLayer.name = "Text"
        titleLayer.constraints.widthType = .auto
        titleLayer.constraints.heightType = .auto
        titleLayer.style.fill.color = .static(.defaultAccent) //.constant(AxModelRef(.accentColorConstantID))
        titleLayer.string = .static("Button")
        button.stackLayer.prebuildAddSublayer(titleLayer)
        
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto
        
        return button
    }
    
    public static let solid = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.name = "Solid Button"

        let titleLayer = try DKTextLayer.make(on: .freestanding)
        titleLayer.name = "Text"
        titleLayer.constraints.widthType = .auto
        titleLayer.constraints.heightType = .auto
        titleLayer.style.fill.color = .static(.white)
        titleLayer.string = .static("Button")
        button.stackLayer.prebuildAddSublayer(titleLayer)

        button.stackLayer.cornerRadius.cornerType = .capsule
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.padding = .init(x: 0, y: 8)
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto
        button.stackLayer.style.fill.isEnabled = true
        button.stackLayer.style.fill.color = .static(.defaultAccent) //.constant(AxModelRef(.accentColorConstantID))

        return button
    }
    

    public static let bordered = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.name = "Bordered Button"

        let titleLayer = try DKTextLayer.make(on: .freestanding)
        titleLayer.name = "Text"
        titleLayer.constraints.widthType = .auto
        titleLayer.constraints.heightType = .auto
        titleLayer.style.fill.color = .static(.teal)
        titleLayer.string = .static("Button")
        button.stackLayer.prebuildAddSublayer(titleLayer)

        button.stackLayer.cornerRadius.cornerType = .fixedSize
        button.stackLayer.cornerRadius.radius = .static(6)
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.padding = .init(x: 0, y: 8)
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto
        button.stackLayer.style.border.isEnabled = true
        button.stackLayer.style.border.width = .static(1)
        button.stackLayer.style.border.color = .static(.teal)

        return button
    }


    public static let gradient = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.name = "Gradient Button"

        let titleLayer = try DKTextLayer.make(on: .freestanding)
        titleLayer.name = "Text"
        titleLayer.constraints.widthType = .auto
        titleLayer.constraints.heightType = .auto
        titleLayer.style.fill.color = .static(.white)
        titleLayer.string = .static("Button")
        button.stackLayer.prebuildAddSublayer(titleLayer)

        button.stackLayer.cornerRadius.cornerType = .capsule
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.padding = .init(x: 0, y: 8)
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto
        button.stackLayer.style.fill.isEnabled = true
        button.stackLayer.style.fill.type = .gradient
        button.stackLayer.style.fill.gradient = .static(BPGradient.neon.withFrom([0, 0.5]).withTo([1, 0.5]))

        return button
    }

    public static let icon = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.constraints.widthValue = .static(32)
        button.constraints.heightValue = .static(32)
        button.name = "Icon Button"

        let iconLayer = try DKIconLayer.make(on: .freestanding)
        iconLayer.name = "Icon"
        iconLayer.icon = .static(.heartCircleFill)
        iconLayer.constraints.widthValue = .static(32)
        iconLayer.constraints.heightValue = .static(32)
        iconLayer.color = .static(.pink)
        button.stackLayer.prebuildAddSublayer(iconLayer)

        button.stackLayer.cornerRadius.cornerType = .capsule
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto

        return button
    }

    public static let iconAndTitle = try! AxModelSession.freestanding.execute {
        let button = try STDButton.make(on: .freestanding)
        button.name = "Icon and Title Button"

        let titleLayer = try DKTextLayer.make(on: .freestanding)
        titleLayer.name = "Text"
        titleLayer.constraints.widthType = .auto
        titleLayer.constraints.heightType = .auto
        titleLayer.string = .static("Button")
        titleLayer.style.fill.color = .static(.white)
        button.stackLayer.prebuildAddSublayer(titleLayer)

        let iconLayer = try DKIconLayer.make(on: .freestanding)
        iconLayer.icon = .static(.mic)
        iconLayer.constraints.widthValue = .static(20)
        iconLayer.constraints.heightValue = .static(20)
        iconLayer.color = .static(.white)
        button.stackLayer.prebuildAddSublayer(iconLayer)

        button.stackLayer.cornerRadius.cornerType = .fixedSize
        button.stackLayer.cornerRadius.radius = .static(6)
        button.stackLayer.alignment = .mid
        button.stackLayer.distribution = .mid
        button.stackLayer.orientation = .horizontal
        button.stackLayer.constraints.widthType = .auto
        button.stackLayer.constraints.heightType = .auto
        button.stackLayer.padding = .init(x: 0, y: 8)
        button.stackLayer.style.fill.isEnabled = true
        button.stackLayer.style.fill.type = .gradient
        button.stackLayer.style.fill.gradient = .static(BPGradient.bluesky.withFrom([0, 0.5]).withTo([1, 0.5]))

        return button
    }
}

extension DKStackLayer {
    static let listStack: DKStackLayer = try! AxModelSession.freestanding.execute {
        func makeCell(_ name: String, icon: BPIcon) throws -> DKStackLayer {
            let cell = try DKStackLayer.make(on: .freestanding)
            cell.orientation = .horizontal
            cell.constraints.widthType = .auto
            cell.constraints.heightType = .auto
            cell.fill.isEnabled = true
            cell.fill.color = .static(.white)
            cell.padding = .init(x: 8, y: 4)
            
            let label = try DKTextLayer.make(on: .freestanding)
            label.string = .static(BPString(name))
            label.constraints.widthType = .auto
            label.constraints.heightType = .auto
            
            let spacer = try DKStackSpacer.make(on: .freestanding)
            
            let iconLayer = try DKIconLayer.make(on: .freestanding)
            iconLayer.icon = .static(icon)
            iconLayer.constraints.widthValue = .static(15)
            iconLayer.constraints.heightValue = .static(15)
            
            cell.prebuildAddSublayer(iconLayer)
            cell.prebuildAddSublayer(spacer)
            cell.prebuildAddSublayer(label)
            
            return cell
        }
        
        let listLayer = try DKStackLayer.make(on: .freestanding)
        listLayer.name = "List"
        listLayer.constraints.widthType = .auto
        listLayer.constraints.heightType = .auto
        
        listLayer.prebuildAddSublayer(try makeCell("Alice", icon: .heart))
        listLayer.prebuildAddSublayer(try makeCell("Bob", icon: .star))
        listLayer.prebuildAddSublayer(try makeCell("Cathy", icon: .bell))
        return listLayer
    }
    
    static let horizontalStack = try! AxModelSession.freestanding.execute {
        let stackLayer = try DKStackLayer.make(on: .freestanding)
        stackLayer.orientation = .horizontal
        stackLayer.name = "HStack"
        
        let layer1 = try DKRectangle.make(on: .freestanding)
        layer1.constraints.widthType = .auto
        layer1.constraints.heightType = .auto
        layer1.style.fill.color = .static(.orange)
        
        let layer2 = try DKRectangle.make(on: .freestanding)
        layer2.constraints.widthType = .auto
        layer2.constraints.heightType = .auto
        layer2.style.fill.color = .static(.orange)
        
        stackLayer.prebuildAddSublayer(layer1)
        stackLayer.prebuildAddSublayer(layer2)
        
        return stackLayer
    }
    
    static let verticalStack = try! AxModelSession.freestanding.execute {
        let stackLayer = try DKStackLayer.make(on: .freestanding)
        stackLayer.orientation = .vertical
        stackLayer.name = "VStack"
        
        let layer1 = try DKRectangle.make(on: .freestanding)
        layer1.constraints.widthType = .auto
        layer1.constraints.heightType = .auto
        layer1.style.fill.color = .static(.orange)
        
        let layer2 = try DKRectangle.make(on: .freestanding)
        layer2.constraints.widthType = .auto
        layer2.constraints.heightType = .auto
        layer2.style.fill.color = .static(.orange)
        
        stackLayer.prebuildAddSublayer(layer1)
        stackLayer.prebuildAddSublayer(layer2)
        
        return stackLayer
    }
}


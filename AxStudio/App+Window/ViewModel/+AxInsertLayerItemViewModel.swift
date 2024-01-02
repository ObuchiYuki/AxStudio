//
//  +AxInsertLayerItemViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/11/11.
//

import AxComponents
import DesignKit
import SwiftEx
import AxDocument
import AxCommand

final class AxInsertLayerItemViewModel {
    let insertButton: ACPopupToolbarButton
    init(_ insertButton: ACPopupToolbarButton) { self.insertButton = insertButton }
    
    func loadDocument(_ document: AxDocument) {
        insertButton.addItem("Rectangle.insert".locarized(), icon: R.Image.Insert.rectangle) {[unowned document] in
            document.execute(AxSetAddShapeCommand(shapeType: .rectangle))
        }
        insertButton.addItem("Ellipse", icon: R.Image.Insert.oval) {[unowned document] in
            document.execute(AxSetAddShapeCommand(shapeType: .ellipse))
        }
        
        insertButton.addSeparator()
        
        insertButton.addItem("Screen.insert".locarized(), icon: R.Image.Insert.screen) {[unowned document] in
            document.execute(AxMakeScreenCommand())
        }
        insertButton.addItem("Text.insert".locarized(), icon: R.Image.Insert.text) {[unowned document] in
            document.execute(AxSetAddShapeCommand(shapeType: .text))
        }
        insertButton.addItem("Image.insert".locarized(), icon: R.Image.Insert.image) {[unowned document] in
            document.execute(AxSetAddShapeCommand(shapeType: .image))
        }
//        insertButton.addItem("Video.insert".locarized(), icon: R.Image.Insert.video) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .video))
//        }
        
        insertButton.addSeparator()
        
//        insertButton.addItem("Button.insert".locarized(), icon: R.Image.Insert.button) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .button))
//        }
//        insertButton.addItem("Icon.insert".locarized(), icon: R.Image.Insert.icon) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .icon))
//        }
//        insertButton.addItem("Icon Button.insert".locarized(), icon: R.Image.Insert.iconButton) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .iconButton))
//        }
//        insertButton.addItem("Text Input.insert".locarized(), icon: R.Image.Insert.textField) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .textInput))
//        }
//        insertButton.addItem("Map.insert".locarized(), icon: R.Image.Insert.map) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .map))
//        }
//        insertButton.addItem("Camera.insert".locarized(), icon: R.Image.Insert.camera) {[unowned document] in
//            document.execute(AxSetAddShapeCommand(shapeType: .camera))
//        }
    }
}

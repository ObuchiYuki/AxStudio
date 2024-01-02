//
//  R.swift
//  AxStudio
//
//  Created by yuki on 2020/04/07.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import Combine
import SwiftEx
import AppKit
import AxComponents

enum R {
    enum SceneIdentifier {
        static let appWindowController = NSStoryboard.SceneIdentifier("AppWindowController")
    }
    enum Color {
        static let toolbar = NSColor(named: "ToolBarColor")!
        static let editorBackgroundColor = NSColor(named: "CanvasBackground")!
        
        static let localDocumentColor = NSColor(hex: 0x007AFF)
        static let cloudDocumentColor = NSColor(hex: 0xFF8A1A)
    }
    enum Size {
        static let selectionBarTopMargin: CGFloat = 5
    }
}

extension R {
    enum Image {
        static let truncationHead = NSImage(named: "truncation_head")!
        static let truncationMiddle = NSImage(named: "truncation_middle")!
        static let truncationTail = NSImage(named: "truncation_tail")!

        static var union = NSImage(named: "union")!
        static var subtract = NSImage(named: "subtract")!
        static var diffrence = NSImage(named: "diffrence")!
        static var intersect = NSImage(named: "intersect")!

        static var detachIcon = NSImage(named: "detach")!

        static var editCodeIcon = NSImage(named: "code")!
        static var editBluePrint = NSImage(named: "edit_blueprint")!

        static var libraryManager = NSImage(named: "library_manager")!

        static var lightAddBtton: NSImage { NSImage(named: "light_add_button")! }
        static var heavyRemoveButton: NSImage { NSImage(named: "heavy_remove_button")! }
        static var trash: NSImage { NSImage(named: "trash")! }
        static var trashMini = NSImage(named: "trash_mini")!

        static let cornerAll = NSImage(named: "corner_all")!
        static let cornerEach = NSImage(named: "corner_each")!

        static let flipHorizontal = NSImage(named: "flip_horizontal")!
        static let flipVertical = NSImage(named: "flip_vertical")!
        
        static let debugWebsocket = NSImage(named: "debug_websocket")!
        static let debugDocument = NSImage(named: "debug_document")!
        static let debugModel = NSImage(named: "debug_model")!
        
        static let debugLogStart = NSImage(named: "debug_log_start")!
        static let debugLogStop = NSImage(named: "debug_log_stop")!
        static let debugLogTrash = NSImage(named: "debug_log_trash")!
        
        static let stackHorizontal = NSImage(named: "stack_horizontal")!
        static let stackVertical = NSImage(named: "stack_vertical")!
        static let stackSpaceHorizontal = NSImage(named: "stack_space_horizontal")!
        static let stackSpaceVertical = NSImage(named: "stack_space_vertical")!
        static let stackPadding = NSImage(named: "stack_padding")!
        static let stackLayoutHorizonatl = NSImage(named: "stack_layout_horizontal")!
        static let stackLayoutVertical = NSImage(named: "stack_layout_vertical")!
        static let stackSpacer = NSImage(named: "stack_spacer")!
        
        static let closeTable = NSImage(named: "close_table_icon")!
        
        static let paddingMinX = NSImage(named: "padding.minX")!
        static let paddingMaxX = NSImage(named: "padding.maxX")!
        static let paddingMinY = NSImage(named: "padding.minY")!
        static let paddingMaxY = NSImage(named: "padding.maxY")!
        
        static let editMini = NSImage(named: "edit_mini")!
        static let lightReload = NSImage(named: "light_reload")!
        
        static let valignTop = NSImage(named: "vtext_top")!
        static let valignCenter = NSImage(named: "vtext_center")!
        static let valignBottom = NSImage(named: "vtext_bottom")!
        
        static let lineSpacing = NSImage(named: "line_spacing")!
        static let charSpacing = NSImage(named: "char_spacing")!
        
        enum Toolbar {
            static let settings = NSImage(named: "settings")!
            static let oval = NSImage(named: "oval")!
            static let ovalFill = NSImage(named: "oval_fill")!
            static let rectangle = NSImage(named: "rectangle")!
            static let rectangleFill = NSImage(named: "rectangle_fill")!
            static let screen = NSImage(named: "screen")!
            static let screenFill = NSImage(named: "screen_fill")!
            static let vector = NSImage(named: "vector")!
            static let run = NSImage(named: "run")!
            static let export = NSImage(named: "export")!
            static let `import` = NSImage(named: "import")!
            static let text = NSImage(named: "text")!
            static let mask = NSImage(named: "mask")!
            static let boolean = NSImage(named: "boolean")!
            static let outline = NSImage(named: "outline")!
            static let symbol = NSImage(named: "symbol")!
            static let union = NSImage(named: "union")!
            static let subtract = NSImage(named: "subtract")!
            static let intersect = NSImage(named: "intersect")!
            static let diffrence = NSImage(named: "diffrence")!
        }
    }
}


extension R.Image {
    enum Insert {
        static let video = NSImage(named: "insert_video")!
        static let oval = NSImage(named: "insert_oval")!
        static let rectangle = NSImage(named: "insert_rectangle")!
        static let screen = NSImage(named: "insert_screen")!
        static let text = NSImage(named: "insert_text")!
        static let image = NSImage(named: "insert_image")!
        static let map = NSImage(named: "insert_map")!
        static let icon = NSImage(named: "insert_icon")!
        static let iconButton = NSImage(named: "insert_icon_button")!
        static let `switch` = NSImage(named: "insert_switch")!
        static let textField = NSImage(named: "insert_text_field")!
        static let segment = NSImage(named: "insert_segment")!
        static let slider = NSImage(named: "insert_slider")!
        static let button = NSImage(named: "insert_button")!
        static let camera = NSImage(named: "insert_camera")!
    }
}

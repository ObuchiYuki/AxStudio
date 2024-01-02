//
//  R+Indicator.swift
//  AxStudio
//
//  Created by yuki on 2020/05/13.
//  Copyright © 2020 yuki. All rights reserved.
//

import AppKit
import AxComponents
import SwiftEx

extension R {
    enum I {
        enum Image {
            static let designTab = NSImage(named: "indicator_design")!
            static let actionTab = NSImage(named: "indicator_action")!
            static let linkTab = NSImage(named: "indicator_link")!

            static let aspectLock = NSImage(named: "aspect_lock")!
            static let aspectUnlock = NSImage(named: "aspect_unlock")!

            enum Align {
                static let allItems = [left, vertical, right, top, horizontal, bottom]
                static let top = NSImage(named: "align_top")!
                static let bottom = NSImage(named: "align_bottom")!
                static let right = NSImage(named: "align_right")!
                static let left = NSImage(named: "align_left")!
                static let horizontal = NSImage(named: "align_horizontal")!
                static let vertical = NSImage(named: "align_vertical")!
            }

            enum TextAlign {
                static let right = NSImage(named: "text_align_right")!
                static let left = NSImage(named: "text_align_left")!
                static let center = NSImage(named: "text_align_center")!
                static let justify = NSImage(named: "text_align_justify")!
            }

            enum TextBox {
                static let line = NSImage(named: "textbox_line")!
                static let box = NSImage(named: "textbox_box")!
            }
        }

        enum Size {
            static let minimumIndicatorWidth: CGFloat = 240
        }
    }

}

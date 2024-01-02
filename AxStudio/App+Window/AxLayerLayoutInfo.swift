//
//  AxLayerLayoutInfo.swift
//  AxStudio
//
//  Created by yuki on 2021/11/26.
//

import AxDocument
import AxComponents
import SwiftEx
import AppKit
import LayoutEngine

enum AxLayerLayoutInfo {
    static func showInfo(_ document: AxDocument, view: NSView) {
        guard let location = view.window?.mouseLocationOutsideOfEventStream, let layer = document.selectedLayers.first else { return }
        let context = document.session.layoutContext
        
        print("------------------------------ Layout Info ------------------------------")
        
        let intrinsicWidth = layer.intrinsicWidth(context, containerWidth: -1)
        let message = """
intrinsicWidth:         \(intrinsicWidth)
intrinsicHeight:        \(layer.intrinsicHeight(for: intrinsicWidth, context, containerHeight: -1))
intrinsicHeight(100):   \(layer.intrinsicHeight(for: 100, context, containerHeight: -1))
intrinsicHeight(200):   \(layer.intrinsicHeight(for: 200, context, containerHeight: -1))
------------------------------
minimumWidth:    \(layer.minimumWidth(context, containerWidth: -1))
minimumHeight:   \(layer.minimumHeight(context, containerHeight: -1))
maximumWidth:    \(layer.maximumWidth(context, containerWidth: -1))
maximumHeight:   \(layer.maximumHeight(context, containerHeight: -1))
"""
        
        print("------------------------------ Layout Info ------------------------------")
        ACDebugMessagePopover(message: message)
            .show(on: view, at: view.convert(location, from: nil))
    }
}

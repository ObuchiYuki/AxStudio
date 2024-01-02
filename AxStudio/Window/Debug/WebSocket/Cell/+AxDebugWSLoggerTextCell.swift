//
//  +AxDebugWSLogger.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import SwiftEx
import AxComponents
import Combine
import AppKit
import AxDocument


final class AxDebugWSLogTextViewController: NSViewController {
    let scrollView = NSTextView.scrollableTextView()
    var textView: NSTextView { self.scrollView.documentView as! NSTextView }
    
    override func loadView() {
        self.view = scrollView
    }
    
    override func chainObjectDidLoad() {
        debugModel.resetLogPublisher
            .sink{[unowned self] str in
                self.textView.textStorage!.setAttributedString(NSAttributedString())
                self.textView.sizeToFit()
                
                self.scrollView.contentView.scroll(to: [0, textView.frame.size.height - scrollView.contentSize.height])
                
            }.store(in: &objectBag)
        debugModel.logPublisher
            .sink{[unowned self] str in
                self.textView.textStorage!.append(str)
                self.textView.sizeToFit()
                
                self.scrollView.contentView.scroll(to: [0, textView.frame.size.height - scrollView.contentSize.height])
                
            }.store(in: &objectBag)
    }
    
    override func viewDidLoad() {
        self.scrollView.hasVerticalScroller = true
        self.textView.isEditable = false
    }
}

class ClipView: NSClipView {
    override var isFlipped: Bool { true }
}

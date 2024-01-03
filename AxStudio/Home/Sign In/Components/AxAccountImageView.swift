//
//  AxAccountImageView.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import SwiftEx
import AppKit
import AppKit
import AxComponents

final public class AxAccountImageView: NSLoadView {
    public var image: NSImage? { get { imageView.image } set { imageView.setResizedImage(newValue) } }
    
    private let imageView = NSImageView()
    
    public convenience init(image: NSImage) {
        self.init()
        self.image = image
    }
    
    override public func onAwake() {
        
        self.wantsLayer = true
        self.layer?.cornerRadius = 35
        self.layer?.masksToBounds = true
        self.snp.makeConstraints{ make in
            make.size.equalTo([70, 70] as CGSize)
        }
        
        self.addSubview(imageView)
        self.imageView.imageScaling = .scaleProportionallyUpOrDown
        self.imageView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

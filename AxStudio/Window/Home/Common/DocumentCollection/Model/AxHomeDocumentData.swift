//
//  AxHomeDocumentItemData.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import SwiftEx
import Foundation
import AppKit
import AxComponents
import AxDocument
import AxModelCore

class AxHomeDocumentData {
    @Observable var title: String
    @Observable var infoText: String
    let documentType: AxDocumentType
    let thumbnail: Promise<NSImage?, Never>?
        
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, documentType: AxDocumentType) {
        self.title = title
        self.infoText = infoText
        self.thumbnail = thumbnail
        self.documentType = documentType
    }
}

class AxHomeLocalDocumentData: AxHomeDocumentData {
    let url: URL
    
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, url: URL) {
        self.url = url
        super.init(title: title, infoText: infoText, thumbnail: thumbnail, documentType: .local)
    }
}

class AxHomeCloudDocumentData: AxHomeDocumentData {
    let documentID: String
    
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, documentID: String) {
        self.documentID = documentID
        super.init(title: title, infoText: infoText, thumbnail: thumbnail, documentType: .cloud)
    }
}

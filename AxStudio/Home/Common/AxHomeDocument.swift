//
//  AxHomeDocumentItemData.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import SwiftEx
import AppKit
import Foundation
import AppKit
import AxComponents
import AxDocument
import AxModelCore

class AxHomeDocument {
    @ObservableProperty var title: String
    @ObservableProperty var infoText: String
    
    enum DocumentType { case local, cloud }
    
    let documentType: DocumentType
    
    let thumbnail: Promise<NSImage?, Never>?
        
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, documentType: DocumentType) {
        self.title = title
        self.infoText = infoText
        self.thumbnail = thumbnail
        self.documentType = documentType
    }
}

class AxHomeLocalDocument: AxHomeDocument {
    let url: URL
    
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, url: URL) {
        self.url = url
        super.init(title: title, infoText: infoText, thumbnail: thumbnail, documentType: .local)
    }
}

class AxHomeCloudDocument: AxHomeDocument {
    let documentID: String
    
    init(title: String, infoText: String, thumbnail: Promise<NSImage?, Never>?, documentID: String) {
        self.documentID = documentID
        super.init(title: title, infoText: infoText, thumbnail: thumbnail, documentType: .cloud)
    }
}

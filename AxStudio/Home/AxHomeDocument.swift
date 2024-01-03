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
    enum DocumentType { case local, cloud }
    
    @ObservableProperty var title: String
    
    let infoText: String
    
    let documentType: DocumentType
    
    let modificationDate: Date
    
    let thumbnail: Promise<NSImage?, Never>?
        
    init(title: String, modificationDate: Date, thumbnail: Promise<NSImage?, Never>?, documentType: DocumentType) {
        self.title = title
        self.modificationDate = modificationDate
        self.thumbnail = thumbnail
        self.documentType = documentType
        
        self.infoText = timeIntervalText(since: modificationDate)
    }
}

final class AxHomeLocalDocument: AxHomeDocument {
    let url: URL
    
    init(title: String, modificationDate: Date, thumbnail: Promise<NSImage?, Never>?, url: URL) {
        self.url = url
        super.init(title: title, modificationDate: modificationDate, thumbnail: thumbnail, documentType: .local)
    }
}

final class AxHomeCloudDocument: AxHomeDocument {
    let documentID: String
    
    init(title: String, modificationDate: Date, thumbnail: Promise<NSImage?, Never>?, documentID: String) {
        self.documentID = documentID
        super.init(title: title, modificationDate: modificationDate, thumbnail: thumbnail, documentType: .cloud)
    }
}

private func timeIntervalText(since date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    guard let before = formatter.string(from: interval) else { return "" }
    return "Edited \(before) before"
}

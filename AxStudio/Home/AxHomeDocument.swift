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
    enum DocumentType { case local, cloud, sandbox }
    
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

private func timeIntervalText(since date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    guard let before = formatter.string(from: interval) else { return "" }
    return "Edited \(before) before"
}

//
//  AxRecentDocumentFormatter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Foundation
import SwiftEx

enum AxRecentDocumentFormatter {
    static func convertToDocumentData(_ content: AxRecentDocumentItem) -> AxHomeDocumentData {
        switch content.document {
        case .local(let document): return convertLocalDocument(document)
        case .cloud(let document): return convertCloudDocument(document)
        }
    }
    private static func convertLocalDocument(_ documentItem: AxRecentDocumentItem.Local) -> AxHomeLocalDocumentData {
        let url = documentItem.url
        let title = url.deletingPathExtension().lastPathComponent
        let infomativeText = self.timeIntervalText(since: documentItem.modificationDate)
        let thumbnail = AxDocumentPreviewManager.shared.localPreview(for: url)
        return AxHomeLocalDocumentData(
            title: title, infoText: infomativeText, thumbnail: thumbnail, url: url
        )
    }
    private static func convertCloudDocument(_ cloudDocument: AxRecentDocumentItem.Cloud) -> AxHomeCloudDocumentData {
        let documentID = cloudDocument.documentData.id
        let title = cloudDocument.documentData.name
        let infomativeText = self.timeIntervalText(since: cloudDocument.modificationDate)
        let thumbnail = AxDocumentPreviewManager.shared.cloudPreview(for: documentID)
        return AxHomeCloudDocumentData(
            title: title, infoText: infomativeText, thumbnail: thumbnail, documentID: documentID
        )
    }
    
    private static func timeIntervalText(since date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        guard let before = formatter.string(from: interval) else { return "" }
        return "Edited \(before) before"
    }
}

//
//  AxRecentDocumentItem.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import AppKit
import AxDocument

final class AxRecentDocumentItem {
    enum Document {
        case cloud(Cloud), local(Local)
    }
    
    struct Local {
        let modificationDate: Date
        let url: URL
    }
    
    struct Cloud {
        let modificationDate: Date
        let authAPI: AxHttpAuthorizedAPIClient
        let documentData: AxDocumentResponce
    }
    
    let document: Document
    
    lazy var modificationDate: Date = {
        switch document {
        case .cloud(let document): return document.modificationDate
        case .local(let document): return document.modificationDate
        }
    }()
    
    init(document: Document) { self.document = document }
}

extension AxRecentDocumentItem {
    func convertToHomeDocument() -> AxHomeDocument {
        switch self.document {
        case .local(let document): return convertLocalDocument(document)
        case .cloud(let document): return convertCloudDocument(document)
        }
    }
    
    private func convertLocalDocument(_ item: AxRecentDocumentItem.Local) -> AxHomeLocalDocument {
        let url = item.url
        let title = url.deletingPathExtension().lastPathComponent
        let infomativeText = self.timeIntervalText(since: item.modificationDate)
        let thumbnail = AxDocumentPreviewManager.shared.localPreview(for: url)
        return AxHomeLocalDocument(
            title: title, infoText: infomativeText, thumbnail: thumbnail, url: url
        )
    }
    private func convertCloudDocument(_ item: AxRecentDocumentItem.Cloud) -> AxHomeCloudDocument {
        let documentID = item.documentData.id
        let title = item.documentData.name
        let infomativeText = self.timeIntervalText(since: item.modificationDate)
        let thumbnail = AxDocumentPreviewManager.shared.cloudPreview(for: documentID)
        return AxHomeCloudDocument(
            title: title, infoText: infomativeText, thumbnail: thumbnail, documentID: documentID
        )
    }

    private func timeIntervalText(since date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        guard let before = formatter.string(from: interval) else { return "" }
        return "Edited \(before) before"
    }

}


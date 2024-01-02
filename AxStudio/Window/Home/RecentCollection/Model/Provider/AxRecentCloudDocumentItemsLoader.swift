//
//  AxRecentCloudDocumentItemsLoader.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import AppKit
import Combine
import SwiftEx
import AxDocument

final class AxRecentCloudDocumentItemsLoader {
    
    var publisher: AnyPublisher<[AxRecentDocumentItem.Cloud], Never> { subject.eraseToAnyPublisher() }
    
    private let subject = CurrentValueSubject<[AxRecentDocumentItem.Cloud], Never>([])
    private var authAPI: AxHttpAuthorizedAPIClient? = nil
    private let dateFormatter = ISO8601DateFormatter() => {
        $0.formatOptions.insert(.withFractionalSeconds)
    }
    private var initialLoaded = false
    private var needsReload = false
    
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        if authAPI == nil { self.subject.send([]) }
        
        self.authAPI = authAPI
        self.reloadItems()
    }
    
    func setNeedsReload() {
        if needsReload { return }; needsReload = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.needsReload = false
            self.reloadItems()
        }
    }
    
    private func reloadItems() {
        guard let authAPI = self.authAPI else { return }
        
        fetchDocumentItems(from: authAPI).sink{ self.subject.send($0) }
    }
    
    private func fetchDocumentItems(from authAPI: AxHttpAuthorizedAPIClient) -> Promise<[AxRecentDocumentItem.Cloud], Never> {
        authAPI.recentDocuments()
            .map{ $0.map{ self.convertToDocumentItem(from: $0, authAPI: authAPI) } }
            .replaceError(with: [])
    }
    
    private func convertToDocumentItem(from res: AxDocumentResponce, authAPI: AxHttpAuthorizedAPIClient) -> AxRecentDocumentItem.Cloud {
        let modificationDate = dateFormatter.date(from: res.lastOpenAt ?? res.updatedAt) ?? Date()
        return AxRecentDocumentItem.Cloud(modificationDate: modificationDate, authAPI: authAPI, documentData: res)
    }
}

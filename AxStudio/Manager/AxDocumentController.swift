//
//  AxDocumentController.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import AppKit

final class AxDocumentController: NSDocumentController {
    
    static func activate() { _ = AxDocumentController() }
    
    static let recentDocumentNotificationName = NSNotification.Name("recentDocumentNotificationName")
    
    override func noteNewRecentDocumentURL(_ url: URL) {
        super.noteNewRecentDocumentURL(url)
        NotificationCenter.default.post(name: AxDocumentController.recentDocumentNotificationName, object: nil)
    }
    
    override func clearRecentDocuments(_ sender: Any?) {
        super.clearRecentDocuments(sender)
        NotificationCenter.default.post(name: AxDocumentController.recentDocumentNotificationName, object: nil)
    }
}


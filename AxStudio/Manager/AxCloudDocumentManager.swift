//
//  AxCloudDocumentOpener.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxModelCore
import AppKit
import AxComponents
import AxDocument
import SwiftEx
import LayoutEngine

private let kOpenDocumentsKey = "openCloudDocuments"

final class AxCloudDocumentManager {
    
    static let closeNotification = Notification.Name("AxCloudDocumentManager.closeNotification")
    
    struct NotificationObject {
        let documentID: String
        let windowController: AxAppWindowController
    }
    
    private var documentIDs: [String] {
        get { userDefaults.array(forKey: kOpenDocumentsKey) as? [String] ?? [] }
        set { userDefaults.set(newValue, forKey: kOpenDocumentsKey) }
    }
    
    var profile: AxUserProfile? { didSet { reopenDocumentIfNeeded() } }
    var homeWindowController: AxHomeWindowController?
    
    private let userDefaults: UserDefaults
    private var authAPI: AxHttpAuthorizedAPIClient? { didSet { reopenDocumentIfNeeded() } }
    private var documentControllers = [String: AxAppWindowController]()
    private var progressPanels = [String: (ACFormPanel, Promise<Void, Error>)]()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        
        // register
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: nil) { notice in
            guard let window = notice.object as? NSWindow else { return }
            guard let (documentID, wc) = self.documentControllers.first(where: { $0.value.window === window }) else { return }
            
            self.unregisterDocumentController(documentID)
            
            let object = NotificationObject(documentID: documentID, windowController: wc)
            NotificationCenter.default.post(name: AxCloudDocumentManager.closeNotification, object: object)
        }
    }
    
    private func reopenDocumentIfNeeded() {
        guard self.authAPI != nil, self.profile != nil else { return }
        self.openUnclosedDocuments(documentIDs: documentIDs)
    }
        
    func setAuthAPI(_ authAPI: AxHttpAuthorizedAPIClient?) {
        self.authAPI = authAPI
        if authAPI == nil {
            for (documentID, controller) in self.documentControllers {
                controller.close()
                self.unregisterDocumentController(documentID)
            }
        }
    }
    
    func openDocument(documentID: String) -> Promise<Void, Error> {
        if let (panel, promise) = self.progressPanels[documentID] {
            panel.makeKey()
            panel.makeMain()
            return promise
        }
        
        return _openDocument(documentID: documentID)
    }
    
    private func _openDocument(documentID: String) -> Promise<Void, Error> {
        guard let authAPI = self.authAPI, let profile = self.profile else {
            return Promise(failure: "Not logined")
        }
        
        // if already opened
        if let documentController = self.documentControllers[documentID] {
            documentController.window?.makeKeyAndOrderFront(nil)
            return Promise(output: ())
        }
        
        // make windowController
        let client = authAPI.connectToRoom(documentID: documentID)
        let session = AxModelSession.publish(client: client, errorHandler: AxToastErrorHandler())
        let documentInfo = authAPI.getDocumentInfo(documentID: documentID)
        
        let progressProvider = ACProgressWindowProvider()
        progressProvider.progressView.startAnimation()
        let progressPanel = ACFormPanel(initialProvider: progressProvider)
        progressPanel.hideCloseButton()
        progressPanel.show()
                 
        // connect to server
        let promise = AxDocument.connect(session: session).combine(documentInfo)
            .peek{ document, info in
                let clientInfo = AxDocument.CloudClientInfo(userProfile: profile)
                document.clientType = .cloud(clientInfo)
                
                let windowController = AxAppWindowController.instantiate()
                windowController.chainObject = document
                windowController.window?.title = info.name
                self.registerDocumentController(documentID, windowController: windowController)
                
                self.showWindow(windowController)
            }
            .finally {
                progressPanel.window.close()
                self.progressPanels[documentID] = nil
            }
            .eraseToVoid()
            .peekError{
                #if DEBUG
                ACToast.debugLog(message: $0)
                #endif
            }
        
        self.progressPanels[documentID] = (progressPanel, promise)
        return promise
    }
    
    private func showWindow(_ windowController: NSWindowController) {
        guard let window = windowController.window else { return beepWarning() }
        // そのうちTabbingやりたい
        window.makeKeyAndOrderFront(nil)
    }
    
    private func openUnclosedDocuments(documentIDs: [String]) {
        self.documentIDs = []
        for documentID in documentIDs {
            self.openDocument(documentID: documentID)
                .catch{ error in
                    #if DEBUG
                    print("Reopen failed:", error)
                    #endif
                }
        }
    }
    

    private func unregisterDocumentController(_ documentID: String) {
        self.documentControllers[documentID] = nil
        self.documentIDs.removeAll(where: { $0 == documentID })
    }
    
    private func registerDocumentController(_ documentID: String, windowController: AxAppWindowController) {
        self.documentControllers[documentID] = windowController
        self.documentIDs.append(documentID)
    }
}

private struct ACProgressWindowProvider: ACFormProvider {
    
    let titleView = ACFormTitleView(title: "Loading Document...")
    let progressView = ACFormProgressBarView()
    
    func provideForm(into panel: ACFormPanel) {
        panel.addFormView(titleView)
        panel.addFormView(progressView)
    }
}

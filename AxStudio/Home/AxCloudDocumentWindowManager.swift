//
//  AxCloudDocumentWindowManager.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import AxModelCore
import AppKit
import AxComponents
import AxDocument
import SwiftEx
import AppKit
import LayoutEngine

final class AxCloudDocumentWindowManager {
    
    static let closeNotification = Notification.Name("AxCloudDocumentManager.closeNotification")
    
    private static let kOpenDocumentsKey = "openCloudDocuments"
    
    struct NotificationObject {
        let documentID: String
        let windowController: AxAppWindowController
    }
    
    
    var profile: AxUserProfile? { didSet { reopenDocumentIfNeeded() } }
    
    private var editingDocumentIDs: [String] {
        get { userDefaults.array(forKey: Self.kOpenDocumentsKey) as? [String] ?? [] }
        set { userDefaults.set(newValue, forKey: Self.kOpenDocumentsKey) }
    }
    
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
            NotificationCenter.default.post(name: Self.closeNotification, object: object)
        }
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
        
        return self._openDocument(documentID: documentID)
    }
    
    private func _openDocument(documentID: String) -> Promise<Void, Error> {
        guard let authAPI = self.authAPI, let profile = self.profile else {
            return .reject("Not logined")
        }
        
        // if already opened
        if let documentController = self.documentControllers[documentID] {
            documentController.window?.makeKeyAndOrderFront(nil)
            return .resolve()
        }
        
        // make windowController
        let client = authAPI.connectToRoom(documentID: documentID)
        let session = AxModelSession(client: client, errorHandle: AxToastErrorHandle())
        let documentInfo = authAPI.getDocumentInfo(documentID: documentID)
        
        let progressProvider = ACProgressWindowProvider()
        progressProvider.progressView.startAnimation()
        let progressPanel = ACFormPanel(initialProvider: progressProvider)
        progressPanel.hideCloseButton()
        progressPanel.show()
                 
        // connect to server
        let promise = AxDocument.connect(to: session).combine(documentInfo)
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
        guard let window = windowController.window else { return __warn_ifDebug_beep_otherwise() }
        window.makeKeyAndOrderFront(nil)
    }
    
    private func openUnclosedDocuments() {
        for documentID in editingDocumentIDs {
            self.openDocument(documentID: documentID)
        }
    }
    
    private func unregisterDocumentController(_ documentID: String) {
        self.documentControllers[documentID] = nil
        self.editingDocumentIDs.removeAll(where: { $0 == documentID })
    }
    
    private func registerDocumentController(_ documentID: String, windowController: AxAppWindowController) {
        self.documentControllers[documentID] = windowController
        self.editingDocumentIDs.append(documentID)
    }
    
    private func reopenDocumentIfNeeded() {
        guard self.authAPI != nil, self.profile != nil else { return }
        self.openUnclosedDocuments()
        self.editingDocumentIDs = []
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

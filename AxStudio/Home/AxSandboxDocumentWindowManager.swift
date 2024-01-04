//
//  File.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import Foundation
import SwiftEx
import AxComponents
import AppKit
import AxDocument
import AxModelCore
import AxModelCoreMockClient

final class AxSandboxDocumentWindowManager {
    
    final class EditingDocument {
        let document: AxHomeSandboxDocument
        let server: AxMockServer<AxMockFileStorage>
        let session: AxModelSession
        let timer: Timer
        var windowController: AxAppWindowController?
        
        init(document: AxHomeSandboxDocument, server: AxMockServer<AxMockFileStorage>, session: AxModelSession, timer: Timer) {
            self.document = document
            self.server = server
            self.session = session
            self.timer = timer
        }
    }
    
    var editingDocuments = [EditingDocument]()
    
    func openDocument(_ document: AxHomeSandboxDocument) throws {
        let documentID = document.metadata.documentID
        
        let fileStorage = AxMockFileStorage(directory: document.fileStorageURL)
        let server = AxMockServer(fileStorage: fileStorage, documentID: documentID)
        server.autoFlush = true
        
        if FileManager.default.fileExists(atPath: document.contentsURL.path) {
            let contents = try Data(contentsOf: document.contentsURL)
            try server.loadStateFromData(contents)
        }
        
        let session = server.makeClient()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if server.updatedAfterLastEncode {
                do {
                    let data = server.encodeStateToData()
                    try data.write(to: document.contentsURL)
                } catch {
                    ACToast.show(message: "Failed to save document.")
                }
            }
        }
        
        let editingDocument = EditingDocument(document: document, server: server, session: session, timer: timer)
        self.editingDocuments.append(editingDocument)
        
        AxDocument.connect(to: session)
            .peek{ axDocument in
                axDocument.clientType = .unknown
                
                let windowController = AxAppWindowController.instantiate()
                windowController.chainObject = axDocument
                windowController.window?.title = document.title
                windowController.window?.makeKeyAndOrderFront(self)
                editingDocument.windowController = windowController
            }
            .catchOnToast("Cannot open sandbox document.")
    }
}

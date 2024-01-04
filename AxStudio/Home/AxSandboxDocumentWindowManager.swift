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
@testable import AxModelCore
import AxModelCoreMockClient
import STDComponents

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
        if FileManager.default.fileExists(atPath: document.contentsURL.path) {
            let contents = try Data(contentsOf: document.contentsURL)
            try server.loadStateFromData(contents)
        }
        server.autoFlush = true
        let session = server.makeClient()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
                
                #warning("現在の実装では、この処理が必要（fragmentSession依存になったため）どこかで消す")
                let page = axDocument.rootNode.appPage
                page.layoutSubtreeImmediately(session.layoutContext)
                page.scan{ layer in
                    if let button = layer as? STDButton {
                        button.stackLayer.scan{ layer in
                            layer.layoutSubtreeImmediately(session.layoutContext)
                        }
                    }
                    layer.layoutSubtreeImmediately(session.layoutContext)
                }
            }
            .catchOnToast("Cannot open sandbox document.")
    }
}

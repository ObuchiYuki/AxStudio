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
import AxModelCoreMockClient

final class AxSandboxDocumentWindowManager {
    func openDocument(_ document: AxSandboxDocument) throws {
        let documentID = document.metadata.documentID
        
        let fileStorage = AxMockFileStorage(directory: document.fileStorageURL)
        let server = AxMockServer(fileStorage: fileStorage, documentID: documentID)
        let contents = try Data(contentsOf: document.contentsURL)

        try server.loadStateFromData(contents)
        let session = server.makeClient()
        
        AxDocument.connect(to: session)
            .peek{ axDocument in
                axDocument.clientType = .unknown
                
                let windowController = AxAppWindowController.instantiate()
                windowController.chainObject = axDocument
                windowController.window?.title = document.title
                windowController.window?.makeKeyAndOrderFront(self)
            }
            .catchOnToast()
    }
}

//
//  AxSandboxDocumentManager.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import Foundation
import SwiftEx
import AxComponents
import AppKit
import AxModelCore

final class AxSandboxDocument: AxHomeDocument {
    let documentURL: URL
    var metadata: Metadata // これを書き換えても AxHomeDocument レベルの書き換えは起こらない
    
    var metaURL: URL { documentURL.appendingPathComponent(Self.metaFilename) }
    var thumbnailURL: URL { documentURL.appendingPathComponent(Self.thumbnailFilename) }
    var fileStorageURL: URL { documentURL.appendingPathComponent(Self.fileStorageFilename) }
    var contentsURL: URL { documentURL.appendingPathComponent(Self.contentsFilename) }
    
    static let metaFilename = "meta.json"
    static let thumbnailFilename = "thumbnail.png"
    static let fileStorageFilename = "files"
    static let contentsFilename = "contents.axbinary"
    
    struct Metadata: Codable {
        let documentID: AxModelDocumentID
        let title: String
        let modificationDate: Date
    }
    
    init(documentURL: URL, metadata: Metadata) {
        self.documentURL = documentURL
        self.metadata = metadata
        
        super.init(
            title: metadata.title,
            modificationDate: metadata.modificationDate,
            thumbnail: nil,
            documentType: .sandbox
        )
    }
}

final class AxSandboxDocumentManager {
    @ObservableProperty var documents: [AxSandboxDocument] = []
    
    private let rootDirectory: URL
    
    let windowManager: AxSandboxDocumentWindowManager
    
    init(rootDirectory: URL, windowManager: AxSandboxDocumentWindowManager) {
        self.rootDirectory = rootDirectory
        self.windowManager = windowManager
        
        self.reloadDocuments()
    }
    
    func openDocument(_ document: AxSandboxDocument) {
        do {
            try self.windowManager.openDocument(document)
        } catch {
            ACToast.showError(message: "Failed to open document.", error: error)
        }
    }
    
    func deleteDocument(_ document: AxSandboxDocument) {
        do {
            try FileManager.default.removeItem(at: document.documentURL)
            self.reloadDocuments()
        } catch {
            ACToast.showError(message: "Failed to delete document.", error: error)
        }
    }
    
    func renameDocument(_ document: AxSandboxDocument, to name: String) {
        document.title = name
        
        do {
            let data = try JSONEncoder().encode(document.metadata)
            try data.write(to: document.metaURL)
        } catch {
            ACToast.showError(message: "Failed to save metadata.", error: error)
        }
    }
    
    func createDocument() {
        do {
            let documentID = AxModelDocumentID.__publish()
            let url = self.rootDirectory.appendingPathComponent(documentID.stringRepresentation)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
            
            let meta = AxSandboxDocument.Metadata(
                documentID: documentID,
                title: "Untitled",
                modificationDate: Date()
            )
            let data = try JSONEncoder().encode(meta)
            try data.write(to: url.appendingPathComponent(AxSandboxDocument.metaFilename))
            
            try FileManager.default.createDirectory(
                at: url.appendingPathComponent(AxSandboxDocument.fileStorageFilename),
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            self.reloadDocuments()
        } catch {
            ACToast.showError(message: "Failed to create document.", error: error)
        }
    }
    
    func openInFinder(_ document: AxSandboxDocument) {
        NSWorkspace.shared.selectFile(document.documentURL.path, inFileViewerRootedAtPath: document.documentURL.path)
    }
    
    func reloadDocuments() {
        let contents = (try? FileManager.default.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)) ?? []
        
        var documents = [AxSandboxDocument]()
        for contentURL in contents {
            do {
                let document = try self.loadDocument(at: contentURL)
                documents.append(document)
            } catch {
                ACToast.showError(message: "Cannot open sandbox document.", error: error)
            }
        }
        self.documents = documents
    }
    
    private func loadDocument(at url: URL) throws -> AxSandboxDocument {
        let metaURL = url.appendingPathComponent(AxSandboxDocument.metaFilename)
        let meta = try JSONDecoder().decode(AxSandboxDocument.Metadata.self, from: Data(contentsOf: metaURL))
        
        return AxSandboxDocument(documentURL: url, metadata: meta)
    }
}

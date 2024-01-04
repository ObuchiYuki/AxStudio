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

final class AxHomeSandboxDocument: AxHomeDocument {
    let documentURL: URL
    let metadata: Metadata
    
    unowned let manager: AxSandboxDocumentManager
    
    var metaURL: URL { documentURL.appendingPathComponent(Self.metaFilename) }
    var thumbnailURL: URL { documentURL.appendingPathComponent(Self.thumbnailFilename) }
    var fileStorageURL: URL { documentURL.appendingPathComponent(Self.fileStorageFilename) }
    var contentsURL: URL { documentURL.appendingPathComponent(Self.contentsFilename) }
    
    override func documentTypeIcon() -> NSImage? { R.Home.Body.localDocumentIcon }
    
    override func documentDefaultThumbnail() -> NSImage? { R.Home.Body.localDocumentDefaultThumbnail }
    
    override func open() { self.manager.openDocument(self) }
    
    override func delete() { self.manager.deleteDocument(self) }
    
    override func provideContextMenu(to menu: NSMenu, _ activateRename: @escaping () -> ()) {
        menu.addItem("Open", action: { self.manager.openDocument(self) })
        menu.addItem("Delete", action: { self.manager.deleteDocument(self) })
        menu.addItem("Rename", action: { activateRename() })
        menu.addItem("Open in Finder", action: { self.manager.openInFinder(self) })
    }
    
    static let metaFilename = "meta.json"
    static let thumbnailFilename = "thumbnail.png"
    static let fileStorageFilename = "files"
    static let contentsFilename = "contents.axbinary"
    
    struct Metadata: Codable {
        let documentID: AxModelDocumentID
        let title: String
        let modificationDate: Date
    }
    
    init(documentURL: URL, metadata: Metadata, manager: AxSandboxDocumentManager) {
        self.documentURL = documentURL
        self.metadata = metadata
        self.manager = manager
        
        super.init(title: metadata.title, modificationDate: metadata.modificationDate, thumbnail: nil)
    }
}

final class AxSandboxDocumentManager {
    @ObservableProperty var documents: [AxHomeSandboxDocument] = []
    
    private let rootDirectory: URL
    
    let windowManager: AxSandboxDocumentWindowManager
    
    init(rootDirectory: URL, windowManager: AxSandboxDocumentWindowManager) {
        self.rootDirectory = rootDirectory
        self.windowManager = windowManager
        
        self.reloadDocuments()
    }
    
    func openDocument(_ document: AxHomeSandboxDocument) {
        do {
            try self.windowManager.openDocument(document)
        } catch {
            ACToast.showError(message: "Failed to open document.", error: error)
        }
    }
    
    func deleteDocument(_ document: AxHomeSandboxDocument) {
        do {
            try FileManager.default.removeItem(at: document.documentURL)
            self.reloadDocuments()
        } catch {
            ACToast.showError(message: "Failed to delete document.", error: error)
        }
    }
    
    func renameDocument(_ document: AxHomeSandboxDocument, to name: String) {
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
            
            
            let meta = AxHomeSandboxDocument.Metadata(
                documentID: documentID,
                title: "Untitled",
                modificationDate: Date()
            )
            let data = try JSONEncoder().encode(meta)
            try data.write(to: url.appendingPathComponent(AxHomeSandboxDocument.metaFilename))
            
            try FileManager.default.createDirectory(
                at: url.appendingPathComponent(AxHomeSandboxDocument.fileStorageFilename),
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            self.reloadDocuments()
        } catch {
            ACToast.showError(message: "Failed to create document.", error: error)
        }
    }
    
    func openInFinder(_ document: AxHomeSandboxDocument) {
        NSWorkspace.shared.selectFile(document.documentURL.path, inFileViewerRootedAtPath: document.documentURL.path)
    }
    
    func reloadDocuments() {
        let contents = (try? FileManager.default.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)) ?? []
        
        var documents = [AxHomeSandboxDocument]()
        for contentURL in contents {
            guard AxModelDocumentID(stringRepresentation: contentURL.lastPathComponent) != nil else { continue }
            
            do {
                let document = try self.loadDocument(at: contentURL)
                documents.append(document)
            } catch {
                ACToast.showError(message: "Cannot open sandbox document.", error: error)
            }
        }
        self.documents = documents
    }
    
    private func loadDocument(at url: URL) throws -> AxHomeSandboxDocument {
        let metaURL = url.appendingPathComponent(AxHomeSandboxDocument.metaFilename)
        let meta = try JSONDecoder().decode(AxHomeSandboxDocument.Metadata.self, from: Data(contentsOf: metaURL))
        
        return AxHomeSandboxDocument(documentURL: url, metadata: meta, manager: self)
    }
}

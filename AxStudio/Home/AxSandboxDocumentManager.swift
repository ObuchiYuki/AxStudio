//
//  AxSandboxDocumentManager.swift
//  AxStudio
//
//  Created by yuki on 2024/01/03.
//

import Foundation
import SwiftEx
import AxModelCoreMockClient

final class AxSandboxDocument {
    let documentURL: URL
    let metadata: Metadata
    
    struct Metadata: Codable {
        let title: String
        let modificationDate: Date
    }
    
    init(documentURL: URL, metadata: Metadata) {
        self.documentURL = documentURL
        self.metadata = metadata
    }
}

final class AxSandboxDocumentManager {
    @ObservableProperty var documents: [AxSandboxDocument] = []
    
    private let rootDirectory: URL
    
    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }
    
    func loadDocuments() throws -> URL {
        let contents = try FileManager.default.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
        
        for content in contents {
            let metaURL = content.appendingPathComponent("metadata.json")
            let dat
            
        }
    }
}

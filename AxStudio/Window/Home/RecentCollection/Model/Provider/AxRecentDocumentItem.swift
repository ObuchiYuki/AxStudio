//
//  AxRecentDocumentItem.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import AxDocument

final class AxRecentDocumentItem {
    enum Document {
        case cloud(Cloud), local(Local)
    }
    struct Local {
        let modificationDate: Date
        let url: URL
    }
    struct Cloud {
        let modificationDate: Date
        let authAPI: AxHttpAuthorizedAPIClient
        let documentData: AxDocumentResponce
    }
    
    let document: Document
    
    lazy var modificationDate: Date = {
        switch document {
        case .cloud(let document): return document.modificationDate
        case .local(let document): return document.modificationDate
        }
    }()
    
    init(document: Document) { self.document = document }
}

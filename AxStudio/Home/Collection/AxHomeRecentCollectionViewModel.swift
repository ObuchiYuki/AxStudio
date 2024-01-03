//
//  AxHomeRecentCollectionPresenter.swift
//  AxStudio
//
//  Created by yuki on 2021/09/18.
//

import Combine
import AppKit
import SwiftEx
import AppKit
import AxComponents
import AxDocument
import CoreAudio
import AudioToolbox

final class AxHomeRecentCollectionViewModel: AxHomeDocumentCollectionViewModel {
    @ObservableProperty var homeDocuments = [AxHomeDocument]()
    
    var homeDocumentsPublisher: AnyPublisher<[AxHomeDocument], Never> {
        self.$homeDocuments.eraseToAnyPublisher()
    }
    
    private let cloudDocumentManager: AxCloudDocumentManager
    
    private let localDocumentManager: AxLocalDocumentManager
    
    private let sandboxDocumentManager: AxSandboxDocumentManager
    
    private var objectBag = Set<AnyCancellable>()
    
    init(
        cloudDocumentManager: AxCloudDocumentManager,
        localDocumentManager: AxLocalDocumentManager,
        sandboxDocumentManager: AxSandboxDocumentManager
    ) {
        self.cloudDocumentManager = cloudDocumentManager
        self.localDocumentManager = localDocumentManager
        self.sandboxDocumentManager = sandboxDocumentManager
        
        self.cloudDocumentManager.$documents.combineLatest(localDocumentManager.$documents, sandboxDocumentManager.$documents)
            .sink{[unowned self] in
                self.homeDocuments = ($0 + $1 + $2).sorted(by: { $0.modificationDate < $1.modificationDate })
            }
            .store(in: &objectBag)
    }
}

extension NSSound {
    static let dragToTrash = NSSound(contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif", byReference: true)
}

extension AxDocument {
    var __accountName: String? {
        get { localStorage["__accountName"] as? String } set { localStorage["__accountName"] = newValue }
    }
}


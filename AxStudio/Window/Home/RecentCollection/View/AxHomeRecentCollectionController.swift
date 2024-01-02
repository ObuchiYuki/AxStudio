//
//  AxHomeRecentCollectionController.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AppKit
import SwiftEx
import AppKit

final class AxHomeRecentCollectionController: AxHomeDocumentCollectionController {
    override var viewModel: AxHomeDocumentCollectionViewModel {
        (chainObject as! AxHomeWindowPresenter).recentCollectionPresenter.viewModel
    }
    
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        
        self.titleSection.title = "Recent Documents"
        self.documentsSection.selectPublisher.sink{ self.openDocument($0)  }.store(in: &objectBag)
    }
    
    private func openDocument(_ row: Int) {
        let data = viewModel.itemData[row]
        self.viewModel.openItemPublisher.send(data)
    }
}

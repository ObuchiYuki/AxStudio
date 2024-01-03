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
    override func chainObjectDidLoad() {
        super.chainObjectDidLoad()
        
        self.titleSection.title = "Recent Documents"
        self.documentsSection.selectPublisher.sink{ self.openDocument($0)  }.store(in: &objectBag)
    }
    
    private func openDocument(_ row: Int) {
        guard let homeViewModel = self.chainObject as? AxHomeViewModel else { return }
        let viewModel = homeViewModel.recentCollectionViewModel
        
        let document = viewModel.homeDocuments[row]
        document.open()
    }
}

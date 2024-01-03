//
//  +AxHomeBodyView.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import AxComponents
import AxDocument

class AxHomeDocumentCollectionController: ACCompositionalCollectionViewController {
    override var interSectionSpacing: CGFloat { 16 }
    
    private(set) lazy var titleSection = AxHomeBodyTitleSection()
    private(set) lazy var documentsSection = AxHomeDocumentCollectionSection(
        viewModel: self.chainObject as! AxHomeDocumentCollectionViewModel
    )
        
    override func chainObjectDidLoad() {
        self.collectionView.isSelectable = true
        self.addSection(titleSection)
        self.addSection(documentsSection)
    }
}


//
//  +ACDocumentCollection.swift
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
import Combine

final class AxHomeDocumentCollectionSection: ACCompositionalSection {
    let viewModel: AxHomeDocumentCollectionViewModel
    
    @ObservableProperty private var documents = [AxHomeDocument]()
    
    var numberOfItems: Int { self.documents.count }
    
    var reloadPublisher: AnyPublisher<Void, Never> { self.$documents.map{_ in () }.eraseToAnyPublisher() }
    
    let selectPublisher = PassthroughSubject<Int, Never>()
    
    private var objectBag = Set<AnyCancellable>()
    
    init(viewModel: AxHomeDocumentCollectionViewModel) {
        self.viewModel = viewModel
        viewModel.homeDocumentsPublisher
            .sink{[unowned self] in self.documents = $0 }.store(in: &objectBag)
    }
    
    func shouldSelectItem(for row: Int) -> Bool { true }
    
    func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemCount = environment.container.contentSize.width == 0 ? 3 : ceil(environment.container.contentSize.width / 300)

        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1/itemCount), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(210)), subitems: [item]
        )
        group.contentInsets = R.Home.Body.sideEdgeInsets
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func makeCell(_ collectionView: NSCollectionView, for row: Int) -> NSCollectionViewItem {
        let item = AxHomeDocumentItem()
        item.itemView.homeDocument = self.documents[row]
        item.selectPublisher.sink{ self.selectPublisher.send(row) }.store(in: &objectBag)
        return item
    }
}
 
final private class AxHomeDocumentItem: NSCollectionViewItem {
    override var isSelected: Bool {
        didSet { itemView.isSelected = isSelected }
    }
    
    let selectPublisher = PassthroughSubject<Void, Never>()
    let itemView = AxHomeDocumentItemView()
    
    @objc func doubleClicked(_ sender: Any) {
        self.selectPublisher.send()
    }
    
    override func loadView() {
        self.view = itemView
        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(doubleClicked))
        gestureRecognizer.numberOfClicksRequired = 2
        gestureRecognizer.delaysPrimaryMouseButtonEvents = false
        self.view.addGestureRecognizer(gestureRecognizer)
    }
}


//
//  AxHomeLargeTitleView.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import AxComponents

final class AxHomeBodyTitleSection: ACCompositionalSection {
    
    var title: String { get { titleView.title } set { titleView.title = newValue } }
    
    let numberOfItems: Int = 1
    
    private let titleView = AxHomeBodyTitleView()
    
    func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let group = NSCollectionLayoutGroup.singleItem(sectionHeight: 42)
        group.contentInsets = R.Home.Body.sideEdgeInsets
        return NSCollectionLayoutSection(group: group)
    }
    
    func makeCell(_ collectionView: NSCollectionView, for row: Int) -> NSCollectionViewItem {
        NSCollectionViewItem.view(titleView)
    }
}

final private class AxHomeBodyTitleView: NSLoadView {
    
    var title: String {
        get { titleLabel.stringValue } set { titleLabel.stringValue = newValue }
    }
    
    private let titleLabel = NSTextField(labelWithString: "")
    private let separator = NSRectangleView()
    
    public override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(42)
        }
        self.addSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        self.titleLabel.snp.makeConstraints{ make in
            make.top.left.equalToSuperview()
        }
        
        self.addSubview(separator)
        separator.fillColor = .quaternaryLabelColor
        self.separator.snp.makeConstraints{ make in
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}


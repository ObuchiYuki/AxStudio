//
//  AxAccountHeaderView.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import SwiftEx
import AppKit
import Combine
import AppKit
import AxComponents

final class AxAccountHeaderView: NSLoadView {
    public var accountImage: NSImage? { get { accountImageView.image } set { accountImageView.image = newValue } }
    public var editPublisher: AnyPublisher<Void, Never> { editButton.actionPublisher.eraseToAnyPublisher() }
    
    private let accountImageView = AxAccountImageView()
    private let editButton = ACColorFillButton()
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(70)
        }
        
        self.addSubview(accountImageView)
        self.accountImageView.snp.makeConstraints{ make in
            make.top.bottom.left.equalToSuperview()
        }
        
        self.addSubview(editButton)
        self.editButton.sideInset = 10
        self.editButton.title = "アカウントを編集"
        self.editButton.cornerStyle = .capsule
        self.editButton.borderWidth = 1
        self.editButton.fillColor = .clear
        self.editButton.textColor = .textColor
        self.editButton.font = .systemFont(ofSize: 12, weight: .medium)
        
        self.editButton.snp.makeConstraints{ make in
            make.bottom.right.equalToSuperview()
            make.height.equalTo(26)
        }
    }
}



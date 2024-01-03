//
//  +AxHomeSidebar.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import Promise
import AxComponents
import AxDocument

final class AxHomeSidebarViewControler: ACSidebarViewController {
    
    @ObservableProperty private var canCreateCloudDocument = false
    
    // Document
    private let localDocumentItem = AxHomeSidebarCreateDocumentItem(documentType: .local)
    private let cloudDocumentItem = AxHomeSidebarCreateDocumentItem(documentType: .cloud)
    private let sandboxDocumentItem = AxHomeSidebarCreateDocumentItem(title: "Sandbox", icon: R.Home.Sidebar.localDocument, color: .systemOrange)
    
    // Debug
    private let restartLocalhostButtonItem = AxHomeSidebarButtonItem(title: "Localhostを追加")
    private let restartAwsButtonItem = AxHomeSidebarButtonItem(title: "AWSを追加")
    private let removeAllDocumentsButtonItem = AxHomeSidebarButtonItem(title: "全Documentを削除")
    private let openURLButtonItem = AxHomeSidebarButtonItem(title: "URLを開く")
    
    // Account
    private let accountViewController = AxModelSidebarAccountViewController()
    
    private var homeViewModel: AxHomeViewModel { self.chainObject as! AxHomeViewModel }
    
    override func viewDidLoad() {
        self.addChild(self.accountViewController)
        self.scrollView.drawsBackground = false
        self.scrollView.addFloatingSubview(accountViewController.view, for: .vertical)
        self.accountViewController.view.snp.makeConstraints{ make in
            make.height.equalTo(56)
            make.bottom.right.left.equalToSuperview()
        }
                        
        self.addItem(ACSidebarTitleItem(title: "Documents", style: .header))
        self.addItem(ACSidebarIconTitleItem(icon: R.Home.Sidebar.recentDocument, title: "Recent Documents"))
        
        self.addItem(ACSidebarTitleItem(title: "Templetes", style: .header))
        self.addItem(ACSidebarIconTitleItem(icon: R.Home.Sidebar.templeteLearrning, title: "Tutorials"))
        self.addItem(ACSidebarIconTitleItem(icon: R.Home.Sidebar.templeteApplication, title: "Applications"))
        
        self.addItem(ACSidebarTitleItem(title: "Create New", style: .header))
        self.addItem(localDocumentItem)
        self.addItem(cloudDocumentItem)
        self.addItem(sandboxDocumentItem)
        
        #if DEBUG
        self.addItem(ACSidebarTitleItem(title: "デバッグ", style: .header))
        self.addItem(restartLocalhostButtonItem)
        self.addItem(restartAwsButtonItem)
        self.addItem(removeAllDocumentsButtonItem)
        self.addItem(openURLButtonItem)
        #endif
    }
        
    override func chainObjectDidLoad() {
        self.homeViewModel.$isConnected.combineLatest(self.homeViewModel.$authAPI)
            .map{ conncted, auth in conncted && auth != nil }
            .sink{[unowned self] in self.cloudDocumentItem.cell.button.isEnabled = $0 }.store(in: &objectBag)
        
        self.cloudDocumentItem.cell.button.actionPublisher
            .sink{[unowned self] in self.createCloudDocument() }.store(in: &objectBag)
        self.localDocumentItem.cell.button.actionPublisher
            .sink{[unowned self] in self.createLocalDocument() }.store(in: &objectBag)
        self.sandboxDocumentItem.cell.button.actionPublisher
            .sink{[unowned self] in self.createSandboxDocument() }.store(in: &objectBag)
    }
    
    private func createSandboxDocument() {
        
    }
    
    private func createCloudDocument() {
        guard let authAPI = self.homeViewModel.authAPI else { return ACToast.show(message: "Can't create document. (No API)") }
        
        authAPI.createDocument()
            .peek{
                self.homeViewModel.cloudDocumentManager.openDocument(documentID: $0.id).catchOnToast()
                self.homeViewModel.recentDocumentManager.reload()
            }
            .catchOnToast("Can't create document.")
    }
    
    private func createLocalDocument() {
        do {
            try NSDocumentController.shared.openUntitledDocumentAndDisplay(true)
        }catch{
            ACToast.show(message: "Can't create document. (Local)")
        }
    }
    
    private func removeAllDocuments() async throws {
        let alert = NSAlert()
        alert.messageText = "全Documentを削除します。"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        let res = alert.runModal()
        guard res == .alertSecondButtonReturn, let authAPI = homeViewModel.authAPI else { return }
    
        authAPI.recentDocuments()
            .flatMap{
                $0.map{ authAPI.deleteDocument(documentID: $0.id) }.combineAll()
            }
            .peek{ _ in
                ACToast.show(message: "Documents Deleted.")
                NSSound.dragToTrash?.play()
                self.homeViewModel.recentDocumentManager.reload()
            }
            .catchOnToast()
    }

}

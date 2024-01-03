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
        
    private var viewModel = AxHomeSidebarViewModel(cloudDocumentManager: <#T##AxCloudDocumentManager#>)
    
    private let localDocumentItem = AxHomeSidebarCreateDocumentItem(documentType: .local)
    private let cloudDocumentItem = AxHomeSidebarCreateDocumentItem(documentType: .cloud)
    
    private let restartLocalhostButtonItem = AxHomeSidebarButtonItem(title: "Localhostを追加")
    private let restartAwsButtonItem = AxHomeSidebarButtonItem(title: "AWSを追加")
    private let removeAllDocumentsButtonItem = AxHomeSidebarButtonItem(title: "全Documentを削除")
    private let openURLButtonItem = AxHomeSidebarButtonItem(title: "URLを開く")
    
    private let accountView = AxHomeSidebarAccountView()
    
    override func viewDidLoad() {
        self.scrollView.drawsBackground = false
        self.scrollView.addFloatingSubview(accountView, for: .vertical)
        self.accountView.snp.makeConstraints{ make in
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
        
        #if DEBUG
        self.addItem(ACSidebarTitleItem(title: "デバッグ", style: .header))
        self.addItem(restartLocalhostButtonItem)
        self.addItem(restartAwsButtonItem)
        self.addItem(removeAllDocumentsButtonItem)
        self.addItem(openURLButtonItem)
        #endif
    }
    
    override func chainObjectDidLoad() {
        self.viewModel.$canCreateCloudDocument
            .sink{[unowned self] in self.cloudDocumentItem.cell.button.isEnabled = $0 }.store(in: &objectBag)
        
        self.cloudDocumentItem.cell.button.actionPublisher
            .sink{[unowned self] in self.viewModel.createCloudDocument() }.store(in: &objectBag)
        self.localDocumentItem.cell.button.actionPublisher
            .sink{[unowned self] in self.viewModel.createLocalDocument() }.store(in: &objectBag)
        
        func openLocalhost() {
            enum __ { static var c = 0 }; __.c += 1
            AxHomeWindowController.make(presenter: .make(api: .localhost(), serviceKey: "com.axstudio.l\(__.c)", requireInternetConnection: self.requireInternetConnection)).showWindow(nil)
        }
        func openAWS() {
            enum __ { static var c = 0 }; __.c += 1
            AxHomeWindowController.make(presenter: .make(api: .production, serviceKey: "com.axstudio.p\(__.c)", requireInternetConnection: self.presenter.requireInternetConnection)).showWindow(nil)
        }
        
        func removeAllDocuments() async throws {
            let alert = NSAlert()
            alert.messageText = "全Documentを削除します。"
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "OK")
            let res = alert.runModal()
            guard res == .alertSecondButtonReturn, let authAPI = presenter.authAPI else { return }
        
            let documents = try await authAPI.recentDocuments().value
            for document in documents {
                try await authAPI.deleteDocument(documentID: document.id).value
                
                DispatchQueue.main.async {
                    ACToast.show(message: "Document Deleted \(document.id)")
                    NSSound.dragToTrash?.play()
                    self.presenter.recentDocumentProvider.cloudDocumentItemLoader.setNeedsReload()
                }
            }
        }
        
        self.restartLocalhostButtonItem.actionPublisher.sink{ openLocalhost() }.store(in: &objectBag)
        self.restartAwsButtonItem.actionPublisher.sink{ openAWS() }.store(in: &objectBag)
        self.removeAllDocumentsButtonItem.actionPublisher.sink{ Promise{ try await removeAllDocuments() }.catchOnToast() }.store(in: &objectBag)
        self.openURLButtonItem.actionPublisher
            .sink{
                guard let string = NSPasteboard.general.string(forType: .string), var components = URLComponents(string: string) else { return NSSound.beep() }
                
                if string.contains("/share/join?token=") {
                    components.scheme = "axstudio"
                }
                
                guard let url = components.url else { return NSSound.beep() }
                
                ACToast.show(message: "Open URL '\(url)'")
                
                NSApp.delegate?.application?(NSApp, open: [url])
            }
            .store(in: &objectBag)
        
        self.accountView.viewModel = presenter.accountViewPresneter.viewModel
    }
}

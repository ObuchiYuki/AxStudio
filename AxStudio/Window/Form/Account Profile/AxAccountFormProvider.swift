//
//  AxAccountFormProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import AxComponents
import AppKit
import SwiftEx
import AppKit
import Combine

final class AxAccountFormProvider: ACFormProvider {
    
    private let titleView = ACFormTitleView(title: "アカウント情報")
    private let headerView = AxAccountHeaderView()
    private let nameRowView = ACFormTableRowView(key: "Name")
    private let emailRowView = ACFormTableRowView(key: "Email")
    private let ruleView = ACFormHorizontalRuleView()
    private let deleteAccountView = ACFormDestructiveActionView(actionText: "アカウントを削除", alertMessage: "アカウントと紐づいたクラウドドキュメントを全て削除します")
    
    private let model: AxAccountFormModel
    private var objectBag = Set<AnyCancellable>()
    
    init(model: AxAccountFormModel) { self.model = model }
    
    func provideForm(into panel: ACFormPanel) {
        panel.addFormView(titleView)
        panel.addFormView(headerView)
        panel.addSpacing(16)
        panel.addFormView(nameRowView)
        panel.addFormView(emailRowView)
        panel.addSpacing(12)
        panel.addFormView(ruleView)
        panel.addFormView(deleteAccountView)
        
        model.$name
            .sink{[unowned self] in nameRowView.value = $0 }.store(in: &objectBag)
        model.$email
            .sink{[unowned self] in emailRowView.value = $0 }.store(in: &objectBag)
        model.$icon
            .sink{[unowned self] in headerView.accountImage = $0 }.store(in: &objectBag)
        
        deleteAccountView.actionPublisher
            .sink{[unowned self] in removeAccount(panel: panel) }.store(in: &objectBag)
        headerView.editPublisher
            .sink{ panel.replaceProvider(AxAccountEditFormProvider(model: self.model)) }.store(in: &objectBag)
    }
    
    private func removeAccount(panel: ACFormPanel) {
        self.titleView.isProgressing = true
        self.model.authAPI.deleteUser()
            .peek{
                ACToast.show(message: "アカウントを削除しました")
                self.model.logoutPublisher.send()
                panel.close(with: .cancel)
            }
            .catchOnToast()
            .sink{ self.titleView.isProgressing = false }
    }
}


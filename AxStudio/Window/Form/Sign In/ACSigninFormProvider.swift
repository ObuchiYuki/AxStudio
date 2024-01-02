//
//  ACSigninPanel.swift
//  AxComponents
//
//  Created by yuki on 2021/09/13.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit
import SwiftEx
import AppKit
import Combine
import AxDocument
import AxComponents

final class ACSigninFormProvider: ACFormProvider {
    
    private let titleView = ACFormTitleView(title: "AxStudioにログイン")
    private let infomativeView = ACFormInfomativeTextView()
    private let errorView = ACFormErrorView()
    private let emailInputForm = ACFormTextInputView(title: "メールアドレス", placeholder: "sample@example.com")
    private let passwordInputForm = ACFormSecureTextInputView(title: "パスワード")
    private let submitView = ACFormSubmitFormView(title: "ログイン")
    private let footerView = ACFormFooterView(infomativeText: "アカウントをお持ちではありませんか？", actionText: "新規登録")
    private let validator = AxSigninFormValidator()
    
    private var objectBag = Set<AnyCancellable>()
    private let model: AxSigninFormPanelModel
    
    init(model: AxSigninFormPanelModel) { self.model = model }
    
    func provideForm(into panel: ACFormPanel) {
        panel.addFormView(titleView)
        panel.addFormView(infomativeView)
        panel.addFormView(errorView)
        panel.addFormView(emailInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 12))
        panel.addFormView(passwordInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 24))
        panel.addFormView(submitView)
        panel.addFormView(ACFormSpacerView(spacing: 24))
        panel.addFormView(footerView)
        panel.addFormView(ACFormSpacerView(spacing: 12))
        
        self.model.$infomativeText
            .sink{[unowned self] in self.infomativeView.infomativeText = $0 }.store(in: &objectBag)
        
        self.emailInputForm.textPublisher
            .sink{[unowned self] in self.validator.email = $0 }.store(in: &objectBag)
        self.validator.emailErrorPublisher(for: self.emailInputForm.submitPublisher)
            .sink{[unowned self] in self.emailInputForm.errorText = $0 }.store(in: &objectBag)
        
        self.passwordInputForm.textPublisher
            .sink{[unowned self] in self.validator.password = $0 }.store(in: &objectBag)
        self.validator.passwordErrorPublisher(for: self.passwordInputForm.submitPublisher)
            .sink{[unowned self] in self.passwordInputForm.errorText = $0 }.store(in: &objectBag)
        
        self.submitView.button.actionPublisher
            .sink{[unowned self] in self.login(panel: panel) }.store(in: &objectBag)
        self.validator.submitEnablePublisher
            .sink{[unowned self] in self.submitView.button.isEnabled = $0 }.store(in: &objectBag)
        
        self.footerView.actionPublisher
            .sink{[unowned self] in panel.replaceProvider(AxCreateAccontFormProvider(model: self.model)) }.store(in: &objectBag)
    }
    
    private func login(panel: ACFormPanel) {
        self.titleView.isProgressing = true
        model.api.login(email: validator.email, pass: validator.password)
            .receive(on: .main)
            .peek{ api in
                self.model.secureLibrary.set(email: self.validator.email, password: self.validator.password)
                self.model.authAPIPublisher.send(api)
                panel.close(with: .OK)
            }
            .catch{ error in
                if error._code == -1004 {
                    self.errorView.errorMessage = "サーバーへ接続ができませんでした"
                } else if error._code == 401 {
                    self.errorView.errorMessage = "メールアドレスもしくはパスワードが間違っています"
                } else if error._code == 400 {
                    self.errorView.errorMessage = "不正なリクエスト"
                } else {
                    self.errorView.errorMessage = "不明なエラー (code: \(error._code))"
                }
            }
            .sink{ self.titleView.isProgressing = false }
    }
}

final private class AxSigninFormValidator {
    @ObservableProperty var email: String = ""
    @ObservableProperty var password: String = ""
    
    func passwordErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.filter{ !$0.isEmpty }
            .map{ AxDataValidator.isValidPassword($0) ? nil : "有効なパスワードを入力してください" }.eraseToAnyPublisher()
    }
    func emailErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.filter{ !$0.isEmpty }
            .map{ AxDataValidator.isValidEmail($0) ? nil : "有効なメールアドレスを入力してください" }.eraseToAnyPublisher()
    }
    
    var submitEnablePublisher: AnyPublisher<Bool, Never> {
        $password.map{ AxDataValidator.isValidPassword($0) }.combineLatest($email.map{ AxDataValidator.isValidEmail($0) })
            .map{ $0 && $1 }.eraseToAnyPublisher()
    }
}

//
//  AxCreateAccontFormProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import AppKit
import SwiftEx
import AppKit
import Combine
import AxDocument
import AxComponents

final class AxCreateAccontFormProvider: ACFormProvider {
    
    private let titleView = ACFormTitleView(title: "AxStudioに新規登録")
    private let infomativeView = ACFormInfomativeTextView()
    private let errorView = ACFormErrorView()
    private let nameInputForm = ACFormTextInputView(title: "お名前", placeholder: "田中太郎")
    private let emailInputForm = ACFormTextInputView(title: "メールアドレス", placeholder: "sample@example.com")
    private let passwordInputForm = ACFormSecureTextInputView(title: "パスワード")
    private let passwordConfirmInputForm = ACFormSecureTextInputView(title: "パスワード (確認)")
    private let submitView = ACFormSubmitFormView(title: "新規登録")
    private let footerView = ACFormFooterView(infomativeText: "アカウントをお持ちですか？", actionText: "ログイン")
    
    private let validator = AxCreateAccountFormValidator()
    private var objectBag = Set<AnyCancellable>()
    private let model: AxSigninFormPanelModel
    
    init(model: AxSigninFormPanelModel) { self.model = model }
    
    func provideForm(into panel: ACFormPanel) {
        panel.addFormView(titleView)
        panel.addFormView(infomativeView)
        panel.addFormView(errorView)
        panel.addFormView(nameInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 12))
        panel.addFormView(emailInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 12))
        panel.addFormView(passwordInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 24))
        panel.addFormView(passwordConfirmInputForm)
        panel.addFormView(ACFormSpacerView(spacing: 24))
        panel.addFormView(submitView)
        panel.addFormView(ACFormSpacerView(spacing: 24))
        panel.addFormView(footerView)
        panel.addFormView(ACFormSpacerView(spacing: 12))
        
        self.model.$infomativeText
            .sink{[unowned self] in self.infomativeView.infomativeText = $0 }.store(in: &objectBag)
        
        self.validator.nameErrorPublisher(for: nameInputForm.submitPublisher)
            .sink{[unowned self] in self.nameInputForm.errorText = $0 }.store(in: &objectBag)
        self.nameInputForm.textPublisher
            .sink{[unowned self] in self.validator.name = $0 }.store(in: &objectBag)
        
        self.validator.emailErrorPublisher(for: emailInputForm.submitPublisher)
            .sink{[unowned self] in self.emailInputForm.errorText = $0 }.store(in: &objectBag)
        self.emailInputForm.textPublisher
            .sink{[unowned self] in self.validator.email = $0 }.store(in: &objectBag)
        
        self.validator.passwordErrorPublisher(for: passwordInputForm.submitPublisher)
            .sink{[unowned self] in self.passwordInputForm.errorText = $0 }.store(in: &objectBag)
        self.passwordInputForm.textPublisher
            .sink{[unowned self] in self.validator.password = $0 }.store(in: &objectBag)
        
        self.validator.confirmPasswordErrorPublisher(for: passwordConfirmInputForm.submitPublisher)
            .sink{[unowned self] in self.passwordConfirmInputForm.errorText = $0 }.store(in: &objectBag)
        self.passwordConfirmInputForm.textPublisher
            .sink{[unowned self] in self.validator.confirmPassword = $0 }.store(in: &objectBag)
        
        self.validator.submitEnablePublisher
            .sink{[unowned self] in self.submitView.button.isEnabled = $0 }.store(in: &objectBag)
        self.submitView.button.actionPublisher
            .sink{[unowned self] in self.createAccount(panel: panel) }.store(in: &objectBag)
        
        self.footerView.actionPublisher
            .sink{[unowned self] in panel.replaceProvider(ACSigninFormProvider(model: self.model)) }.store(in: &objectBag)
    }
    
    private func createAccount(panel: ACFormPanel) {
        
        self.titleView.isProgressing = true
        self.model.api.createAccount(name: validator.name, email: validator.email, pass: validator.password)
            .peek{ api in
                self.model.secureLibrary.set(email: self.validator.email, password: self.validator.password)
                self.model.authAPIPublisher.send(api)
                panel.close(with: .OK)
            }
            .catch{err in self.errorView.errorMessage = "アカウントを作成できませんでした"; print(err) }
            .sink{ self.titleView.isProgressing = false }
    }
}

final private class AxCreateAccountFormValidator {
    
    @ObservableProperty var name: String = ""
    @ObservableProperty var email: String = ""
    @ObservableProperty var password: String = ""
    @ObservableProperty var confirmPassword: String = ""
    
    func nameErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.map{ AxDataValidator.isValidName($0) ? nil : "お名前を入力してください" }.eraseToAnyPublisher()
    }
    func passwordErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.map{ AxDataValidator.isValidPassword($0) ? nil : "8文字以上のパスワードを入力してください" }.eraseToAnyPublisher()
    }
    func confirmPasswordErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.map{ $0 == self.password ? nil : "パスワードが一致しません" }.eraseToAnyPublisher()
    }
    func emailErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.map{ AxDataValidator.isValidEmail($0) ? nil : "有効なメールアドレスを入力してください" }.eraseToAnyPublisher()
    }
    
    var submitEnablePublisher: AnyPublisher<Bool, Never> {
        [
            $password.map{ AxDataValidator.isValidPassword($0) }.eraseToAnyPublisher(),
            $email.map{ AxDataValidator.isValidEmail($0) }.eraseToAnyPublisher(),
            $name.map{ AxDataValidator.isValidName($0) }.eraseToAnyPublisher(),
            $confirmPassword.combineLatest($password).map{ $0 == $1 }.eraseToAnyPublisher()
        ]
        .combineLatest.map{ $0.allSatisfy{ $0 } }.eraseToAnyPublisher()
    }
}



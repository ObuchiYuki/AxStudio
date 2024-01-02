//
//  AxAccountEditFormProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import AxComponents
import AppKit
import SwiftEx
import Combine
import AxDocument

final class AxAccountEditFormProvider: ACFormProvider {
    private let titleView = ACFormTitleView(title: "アカウントを編集")
    private let errorView = ACFormErrorView()
    private let iconEditView = AxAccountIconEditView()
    private let nameInputForm = ACFormTextInputView(title: "お名前", placeholder: "田中太郎")
    private let emailInputForm = ACFormTextInputView(title: "メールアドレス", placeholder: "sample@example.com")
    private let footerView = ACFormFooterView(infomativeText: "", actionText: "パスワードを変更")
    private let buttonsView = ACFormButtonsView()
    
    private let model: AxAccountFormModel
    private let validator: AxAccountEditFormValidator
    private var objectBag = Bag()
    
    init(model: AxAccountFormModel) {
        self.model = model
        self.validator = AxAccountEditFormValidator(name: model.name, email: model.email)
    }
    
    func provideForm(into panel: ACFormPanel) {
        let submitButton = buttonsView.addOKButton()
        buttonsView.addCancelButton{ panel.replaceProvider(AxAccountFormProvider(model: self.model)) }
        
        panel.addFormView(titleView)
        panel.addFormView(errorView)
        panel.addFormView(iconEditView)
        panel.addSpacing(16)
        panel.addFormView(nameInputForm)
        panel.addSpacing(12)
        panel.addFormView(emailInputForm)
        panel.addSpacing(18)
//        panel.addFormView(footerView)
//        panel.addSpacing(18)
        panel.addFormView(buttonsView)
        panel.addSpacing(12)
         
        self.model.$name
            .sink{[unowned self] in self.nameInputForm.text = $0 }.store(in: &objectBag)
        self.model.$email
            .sink{[unowned self] in self.emailInputForm.text = $0 }.store(in: &objectBag)
        
        self.model.$icon
            .sink{[unowned self] in self.iconEditView.image = $0 }.store(in: &objectBag)
        self.iconEditView.imagePublisher
            .sink{[unowned self] in self.updateIcon($0) }.store(in: &objectBag)
                
        self.emailInputForm.textPublisher
            .sink{[unowned self] in self.validator.email = $0 }.store(in: &objectBag)
        self.validator.emailErrorPublisher(for: self.emailInputForm.submitPublisher)
            .sink{[unowned self] in self.emailInputForm.errorText = $0 }.store(in: &objectBag)
        
        self.nameInputForm.textPublisher
            .sink{[unowned self] in self.validator.name = $0 }.store(in: &objectBag)
        self.validator.nameErrorPublisher(for: self.nameInputForm.submitPublisher)
            .sink{[unowned self] in self.nameInputForm.errorText = $0 }.store(in: &objectBag)
        
        submitButton.actionPublisher
            .sink{[unowned self] in self.updateAccount(panel: panel) }.store(in: &objectBag)
        self.validator.submitEnablePublisher
            .sink{ submitButton.isEnabled = $0 }.store(in: &objectBag)
        
        footerView.actionPublisher
            .sink{ panel.replaceProvider(AxAccountEditPasswordProvider(model: self.model)) }.store(in: &objectBag)
    }
    
    private func updateIcon(_ image: NSImage) {
        guard let iconData = image.png else { assertionFailure("No icon data"); return NSSound.beep() }
        self.titleView.isProgressing = true
        
        self.model.authAPI.updateIcon(icon: iconData)
            .peek{
                self.applyNewIcon($0)
                ACToast.show(message: "アイコンを更新しました")
            }
            .catch{ self.errorView.errorMessage = "更新に失敗しました"; print($0) }
            .sink{ self.titleView.isProgressing = false }
    }
    
    private func updateAccount(panel: ACFormPanel) {
        self.titleView.isProgressing = true
        
        self.model.authAPI.updateProfile(name: validator.name, email: validator.email)
            .peek{
                self.applyNewProfile($0)
                ACToast.show(message: "アカウント情報を更新しました")
                panel.replaceProvider(AxAccountFormProvider(model: self.model))
            }
            .catch{ self.errorView.errorMessage = "更新に失敗しました"; print($0) }
            .sink{ self.titleView.isProgressing = false }
    }
    
    private func applyNewIcon(_ profile: AxUserProfile) {
        if let profileURL = profile.profileURL {
            URLSession.shared.data(for: profileURL)
                .receive(on: .main)
                .peek{ if let icon = NSImage(data: $0) { self.model.icon = icon }}
                .catchOnToast()
        }
    }
    
    private func applyNewProfile(_ profile: AxUserProfile) {
        self.model.name = profile.name
        self.model.email = profile.email
        
        model.secureLibrary.set(email: profile.email)
    }
}

final private class AxAccountEditFormValidator {
    @Observable var name: String
    @Observable var email: String
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
    func nameErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.filter{ !$0.isEmpty }
            .map{ AxDataValidator.isValidName($0) ? nil : "1文字以上の名前を入力してください" }.eraseToAnyPublisher()
    }
    func emailErrorPublisher(for submit: AnyPublisher<String, Never>) -> AnyPublisher<String?, Never> {
        submit.filter{ !$0.isEmpty }
            .map{ AxDataValidator.isValidEmail($0) ? nil : "有効なメールアドレスを入力してください" }.eraseToAnyPublisher()
    }
    
    var submitEnablePublisher: AnyPublisher<Bool, Never> {
        $name.map{ AxDataValidator.isValidName($0) }.combineLatest($email.map{ AxDataValidator.isValidEmail($0) })
            .map{ $0 && $1 }.eraseToAnyPublisher()
    }
}

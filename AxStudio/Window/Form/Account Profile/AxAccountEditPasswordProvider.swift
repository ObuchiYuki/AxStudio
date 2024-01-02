//
//  AxAccountEditPasswordProvider.swift
//  AxStudio
//
//  Created by yuki on 2021/09/20.
//

import AxComponents
import AppKit
import SwiftEx
import Combine

final class AxAccountEditPasswordProvider: ACFormProvider {
    private let titleView = ACFormTitleView(title: "パスワードを変更")
    private let errorView = ACFormErrorView()

    private let currentPasswordInputForm = ACFormSecureTextInputView(title: "現在のパスワード")
    private let newPasswordInputForm = ACFormSecureTextInputView(title: "新しいパスワード")
    private let newPasswordConfirmInputForm = ACFormSecureTextInputView(title: "新しいパスワード(確認)")
    private let buttonsView = ACFormButtonsView()
    
    private let model: AxAccountFormModel
    private var objectBag = Bag()
    
    init(model: AxAccountFormModel) { self.model = model }
    
    func provideForm(into panel: ACFormPanel) {
        buttonsView.addOKButton{ panel.replaceProvider(AxAccountEditFormProvider(model: self.model)) }
        buttonsView.addCancelButton{ panel.replaceProvider(AxAccountEditFormProvider(model: self.model)) }
        
        panel.addFormView(titleView)
        panel.addFormView(errorView)
        panel.addFormView(currentPasswordInputForm)
        panel.addSpacing(12)
        panel.addFormView(newPasswordInputForm)
        panel.addSpacing(12)
        panel.addFormView(newPasswordConfirmInputForm)
        panel.addSpacing(18)
        panel.addFormView(buttonsView)
        panel.addSpacing(12)
    }
}

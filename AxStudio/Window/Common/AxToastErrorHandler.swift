//
//  AxToastErrorHandler.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxModelCore
import AxComponents

final class AxToastErrorHandler: AxModelErrorHandler {
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            #if DEBUG
            ACToast.debugLog(message: error)
            #else
            ACToast.show(message: "内部的なエラーが発生しました。(\(error._code))")
            #endif
        }
    }
}

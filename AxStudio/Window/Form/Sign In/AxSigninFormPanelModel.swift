//
//  AxSigninFormPanelModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import SwiftEx
import AxDocument
import Combine

final class AxSigninFormPanelModel {
    let secureLibrary: AxSecureSigninInfoLibrary
    let api: AxHttpAPIClient
    let reachability: Reachability
    
    let authAPIPublisher = PassthroughSubject<AxHttpAuthorizedAPIClient, Never>()
    
    @ObservableProperty var infomativeText: String = ""
    
    init(api: AxHttpAPIClient, secureLibrary: AxSecureSigninInfoLibrary, reachability: Reachability) {
        self.api = api
        self.secureLibrary = secureLibrary
        self.reachability = reachability
    }
}

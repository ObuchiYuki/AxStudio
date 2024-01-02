//
//  AxHttpAPIClient+Production.swift
//  AxStudio
//
//  Created by yuki on 2021/09/19.
//

import AxDocument

extension AxHttpAPIClient {
    static let production = AxHttpAPIClient(domain: "api-axstudio.com", isHttps: true)
}

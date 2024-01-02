//
//  AxBuildinMediaFileProxy.swift
//  AxStudio
//
//  Created by yuki on 2021/11/30.
//

import AxModelCore
import SwiftEx
import AppKit

enum AxBuildinMediaError: Error {
    case unkownPath
}

final class AxBuildinMediaFileProxy: AxModelMediaFileProxy {
    static let scheme: String = "buildin"
    
    private var resourceMap = [String: Data]()
    
    func dataPromise(for path: String) -> Promise<Data, Error> {
        guard let data = resourceMap[path] else {
            assertionFailure("Unkown path \(path)")
            return Promise(failure: AxBuildinMediaError.unkownPath)
        }
        return Promise(output: data)
    }
    
    func register(_ image: NSImage, for path: String) {
        self.resourceMap[path] = image.png
    }
}

extension AxBuildinMediaFileProxy {
    static let `default`: AxBuildinMediaFileProxy = {
        let proxy = AxBuildinMediaFileProxy()
        proxy.register(NSImage(named: "no_image")!, for: "empty")
        proxy.register(NSImage(named: "00_m")!, for: "tail")
        return proxy
    }()
}

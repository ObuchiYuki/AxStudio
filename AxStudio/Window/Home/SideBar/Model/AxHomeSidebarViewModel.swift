//
//  AxHomeSidebarViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import AppKit
import SwiftEx
import AppKit
import Combine
import AxDocument

final class AxHomeSidebarViewModel {
    
    @ObservableProperty var canCreateCloudDocument = false
    
    let createCloudDocumentPublisher = PassthroughSubject<Void, Never>()
    let createLocalDocumentPublisher = PassthroughSubject<Void, Never>()
        
    func createCloudDocument() {
        createCloudDocumentPublisher.send()
    }
    func createLocalDocument() {
        createLocalDocumentPublisher.send()
    }
}


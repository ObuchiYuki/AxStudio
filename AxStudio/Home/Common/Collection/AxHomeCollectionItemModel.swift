//
//  +AxHomeDocumentItemModel.swift
//  AxStudio
//
//  Created by yuki on 2021/09/13.
//

import Combine
import Foundation
import SwiftEx
import AppKit

protocol AxHomeDocumentCollectionViewModel {
    var homeDocumentsPublisher: AnyPublisher<[AxHomeDocument], Never> { get }
}

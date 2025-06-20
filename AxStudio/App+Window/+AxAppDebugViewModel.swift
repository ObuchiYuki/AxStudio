//
//  +AxAppDebugViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/11/12.
//

import AxDocument
import BluePrintKit
import Combine
import AxCommand
import SwiftEx
import AppKit
import DesignKit
import STDComponents

final class AxAppDebugViewModel {
    
    private var objectBag = Set<AnyCancellable>()
    
    func loadDocument(_ document: AxDocument) {
        if DebugSettings.Load.showFragments {
            #warning("現在はできない")
//            document.session.fragmentHandler.sender.publisher().sink{ print($0) }.store(in: &objectBag)
        }
        if DebugSettings.Load.showExpression {
            DispatchQueue.main.async {
                guard let list = document.rootNode.appPage.layers.first else { return }
                document.execute(AxSelectLayerCommand(select: .to(list)))
            }
        }
    }
}

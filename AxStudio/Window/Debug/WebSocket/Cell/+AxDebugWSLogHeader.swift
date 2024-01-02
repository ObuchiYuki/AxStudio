//
//  AxDebugWSLogTextHeaderController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/09.
//

import SwiftEx
import AxComponents
import Combine
import AppKit
import AxDocument
import SocketIO

final class AxDebugWSLogHeaderController: NSViewController {

    private let cell = AxDebugWSLogHeaderView()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }
        
        client.manager.config.insert(.logger(AxDebugSocketLogger.shared))
        
        AxDebugSocketLogger.shared.logPublisher
            .sink{[unowned self] (type, message, color) in
                debugModel.sendLog(type: type, message: message, color: color)
            }.store(in: &objectBag)
        
        self.cell.startButton.actionPublisher
            .sink{ AxDebugSocketLogger.shared.log = true }.store(in: &objectBag)
        self.cell.stopButton.actionPublisher
            .sink{ AxDebugSocketLogger.shared.log = false }.store(in: &objectBag)
        self.cell.resetButton.actionPublisher
            .sink{[unowned self] in debugModel.resetLogPublisher.send() }.store(in: &objectBag)
    }
}

final private class AxDebugWSLogHeaderView: NSLoadView {
    let titleLabel = ACAreaLabel_(title: "Logger")
    let startButton = ACImageButton_(image: R.Image.debugLogStart)
    let stopButton = ACImageButton_(image: R.Image.debugLogStop)
    let resetButton = ACImageButton_(image: R.Image.debugLogTrash)
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(21)
        }
        self.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(resetButton)
        self.resetButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
        
        self.addSubview(stopButton)
        self.stopButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.resetButton.snp.left).offset(-4)
        }
        
        self.addSubview(startButton)
        self.startButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.stopButton.snp.left).offset(-4)
        }
    }
}

//
//  AxDebugWSLoggerViewController.swift
//  AxStudio
//
//  Created by yuki on 2021/10/08.
//

import AppKit
import AxComponents
import AxDocument

final class AxDebugWSLoggerViewController: NSViewController {
    let header = AxDebugWSLogHeaderController()
    let textView = AxDebugWSLogTextViewController()
    
    override func loadView() { self.view = NSView() }
    
    override func chainObjectDidLoad() {
        guard let client = debugModel.document.session.client as? AxHttpDocumentClient else { return }
        
        client.socket.on(clientEvent: .reconnectAttempt) {[unowned self] data, ark in
            debugModel.sendLog(type: "Debug", message: "Reconnect Attempt \"\(data[0])\"", color: .blue)
        }
        
        client.socket.on(clientEvent: .reconnect) {[unowned self] data, ark in
            debugModel.sendLog(type: "Debug", message: "Reconnect \"\(data[0])\"", color: .blue)
        }
    }
    
    override func viewDidLoad() {
        self.addChild(header)
        self.view.addSubview(header.view)
        self.header.view.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(4)
            make.right.left.equalToSuperview()
        }
        
        self.addChild(textView)
        self.view.addSubview(textView.view)
        self.textView.view.snp.makeConstraints{ make in
            make.top.equalTo(self.header.view.snp.bottom).offset(4)
            make.right.bottom.left.equalToSuperview()
        }
    }
}


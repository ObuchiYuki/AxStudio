//
//  +AxBluePrintHeaderView.swift
//  AxStudio
//
//  Created by yuki on 2021/11/22.
//

import AppKit
import SwiftEx
import DesignKit
import BluePrintKit
import AxComponents
import Combine

final class AxBluePrintHeaderViewController: NSViewController {
    
    let headerView = AxBluePrintEditorHeaderView()
    
    override func loadView() { view = headerView }
    
    override func chainObjectDidLoad() {
        document.currentNodeContainerp
            .sink{[unowned self] in
                self.headerView.infomativeLabel.isHidden = false
                self.headerView.typeView.isHidden = true
                if let expr = $0 as? BPExpression {
                    headerView.infomativeLabel.stringValue = "Expression"
                    self.headerView.typeView.isHidden = false
                    if let type = expr.resultNode?.type {
                        headerView.typeView.type = type
                    }
                } else if $0 is BPStatement {
                    headerView.infomativeLabel.stringValue = "Action"
                } else {
                    self.headerView.infomativeLabel.isHidden = true
                }
            }
            .store(in: &objectBag)
    }
}

final class AxBluePrintEditorHeaderView: NSLoadView {
    
    let stackView = NSStackView()
    let infomativeLabel = NSTextField(labelWithString: "")
    let typeView = AxBluePrintTypeView()
    
    override func onAwake() {
        self.addSubview(stackView)
        self.stackView.edgeInsets = .init(x: 16, y: 0)
        self.stackView.snp.makeConstraints{ make in
            make.top.left.bottom.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(typeView)
        
        self.stackView.addArrangedSubview(infomativeLabel)
        self.infomativeLabel.font = .systemFont(ofSize: 12)
    }
}

final class AxBluePrintTypeView: NSLoadStackView {
    
    var type: BPType = .bool {
        didSet{
            self.typeTip.type = type
            self.typeLabel.bind(to: type.namep, \.stringValue)
        }
    }
    
    private let typeTip = ACTypeTip()
    private let typeLabel = NSTextField(labelWithString: "String")
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.textColor.withAlphaComponent(0.1).cgColor
    }
    
    override func onAwake() {
        self.edgeInsets = .init(x: 6, y: 0)
        
        self.snp.makeConstraints{ make in
            make.height.equalTo(16)
        }
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        
        self.addArrangedSubview(typeTip)
        self.addArrangedSubview(typeLabel)
        self.typeLabel.font = .systemFont(ofSize: AxComponents.R.FontSize.control)
        self.typeTip.type = .bool
        self.typeLabel.textColor = .secondaryLabelColor
    }
}


protocol Bindable: AnyObject {
    var objectBag: Set<AnyCancellable> { get set }
}
extension NSObject: Bindable {}

extension Bindable {
    public func bind<P: Publisher, U>(to publiaher: P, _ keyPath: ReferenceWritableKeyPath<Self, U>) where P.Output == U, P.Failure == Never {
        publiaher.sink{[unowned self] in self[keyPath: keyPath] = $0 }.store(in: &objectBag)
    }
    
    public func bind<P: Publisher, U>(to publiaher: P, _ writer: @escaping (Self, U) -> ()) where P.Output == U, P.Failure == Never {
        publiaher.sink{[unowned self] in writer(self, $0) }.store(in: &objectBag)
    }
}

//
//  +AxNodeInput.swift
//  AxStudio
//
//  Created by yuki on 2021/11/13.
//

import BluePrintKit
import Combine
import AppKit
import AxComponents
import SwiftEx
import Neontetra

final class ACNodeInputCell: ACGridView {
    var title: String { get { titleLabel.stringValue } set { titleLabel.stringValue = newValue } }
    var type: BPType { get { valueWell.type } set { valueWell.type = newValue } }
    var value: BPValue? { get { valueWell.value } set { valueWell.value = newValue } }
    
    var valuePublisher: AnyPublisher<BPValue?, Never> { valueWell.valuePublisher }
    
    private let titleLabel = ACAreaLabel_(title: "Value: ", alignment: .right)
    private let valueWell = ACValueWell_()
    
    override func onAwake() {
        self.addItem3(titleLabel, row: 0, column: 0)
        self.titleLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)        
        self.addItem3(valueWell, row: 0, column: 1, length: 2)
    }
}

extension NEInputSocket {
    var inputCell: ACNodeInputCell { data.localCache("input.cell", ACNodeInputCell()) }
}

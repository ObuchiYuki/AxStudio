//
//  AxBluePrintNodeLibraryBuilder.swift
//  AxStudio
//
//  Created by yuki on 2021/11/15.
//

import AxComponents
import BluePrintKit

enum AxBluePrintNodeLibraryBuilder {
    static let statementLibrary: ACNodePickerLibrary = {
        let library = ACNodePickerLibrary()
        
        library.addCategoryItem("JSON Path", message: "Access to json value.", .network, make: .node(BPJSONPathNode.make))
        library.addCategoryItem("Network", message: "Send an API request.", .network, make: .node(BPNetworkNode.make))
        library.addCategoryItem("Network (Advanced)", message: "Send an API request.", .network, make: .node(BPAdvancedNetworkNode.make))
        
        library.addCategoryItem("If", message: "", .flow, make: .node {
            try BPIfNode.make(on: $0)
        })
        library.addCategoryItem("Repeat Count", message: "", .flow, make: .node {
            try BPRepeatNode.make(on: $0)
        })
        library.addCategoryItem("Sequence", message: "", .flow, make: .node {
            try BPSequenceNode.make(on: $0)
        })
        library.addCategoryItem("Switch", message: "", .flow, make: .node {
            try BPSwitchNode.make(on: $0)
        })
        library.addCategoryItem("Foreach", message: "", .flow, make: .node {
            try BPForEachNode.make(on: $0)
        })
        
        library.addCategoryItem("Print Log", message: "", .util, make: .node {
            try BPPrintNode.make(on: $0)
        })
        library.addCategoryItem("Print Text", message: "", .util, make: .node {
            try BPPrintTextNode.make(on: $0)
        })
        
        library.addCategoryItem("+", message: "Add two values together, or join two strings.", .math, make: .node {
            try BPAdditionNode.make(on: $0)
        })
        library.addCategoryItem("-", message: "Subtract a value from a base value.", .math, make: .node(BPSubtractNode.make))
        library.addCategoryItem("×", message: "Multiply two values.", .math, make: .node(BPMultiplicationNode.make))
        library.addCategoryItem("÷", message: "Divide a value by a value.", .math, make: .node(BPDivisionNode.make))
        
        library.addCategoryItem("Not", message: "", .math, make: .node(BPNotNode.make))
        library.addCategoryItem("Or", message: "", .math, make: .node(BPOrNode.make))
        library.addCategoryItem("And", message: "", .math, make: .node(BPAndNode.make))
        
        library.addCategoryItem("Witch", message: "", .flow, make: .node(BPTernaryExprNode.make))
        
        library.addCategoryItem("Float to Int", message: "", .flow, make: .node(BPFloatToInt.make))
        library.addCategoryItem("Int to Float", message: "", .flow, make: .node(BPIntToFloat.make))
        library.addCategoryItem("String to Int", message: "", .flow, make: .node(BPStringToInt.make))
        library.addCategoryItem("Int to String", message: "", .flow, make: .node(BPIntToString.make))
        library.addCategoryItem("Float to String", message: "", .flow, make: .node(BPFloatToString.make))
        
        library.addCategoryItem("Array Length", message: "", .util, make: .node(BPArrayLengthNode.make))
        
        return library
    }()
    
    static let expressionLibrary: ACNodePickerLibrary = {
        let library = ACNodePickerLibrary()
        
        library.addCategoryItem("+", message: "Add two values together, or join two strings.", .math, make: .node(BPAdditionNode.make))
        library.addCategoryItem("-", message: "Subtract a value from a base value.", .math, make: .node(BPSubtractNode.make))
        library.addCategoryItem("×", message: "Multiply two values.", .math, make: .node(BPMultiplicationNode.make))
        library.addCategoryItem("÷", message: "Divide a value by a value.", .math, make: .node(BPDivisionNode.make))
        
        library.addCategoryItem("Not", message: "Message", .math, make: .node(BPNotNode.make))
        library.addCategoryItem("Or", message: "Message", .math, make: .node(BPOrNode.make))
        library.addCategoryItem("And", message: "Message", .math, make: .node(BPAndNode.make))
        
        library.addCategoryItem("Witch", message: "Message", .flow, make: .node(BPTernaryExprNode.make))
        
        library.addCategoryItem("Float to Int", message: "Message", .flow, make: .node(BPFloatToInt.make))
        library.addCategoryItem("Int to Float", message: "Message", .flow, make: .node(BPIntToFloat.make))
        library.addCategoryItem("String to Int", message: "Message", .flow, make: .node(BPStringToInt.make))
        library.addCategoryItem("Int to String", message: "Message", .flow, make: .node(BPIntToString.make))
        library.addCategoryItem("Float to String", message: "Message", .flow, make: .node(BPFloatToString.make))

        return library
    }()
}


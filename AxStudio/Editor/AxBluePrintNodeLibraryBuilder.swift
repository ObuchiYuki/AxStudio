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
        
        library.addCategoryItem("JSON Path", message: "Access to json value.", .network, make: .node{
            try BPJSONPathNode.make(on: $0)
        })
        library.addCategoryItem("Network", message: "Send an API request.", .network, make: .node{
            try BPNetworkNode.make(on: $0)
        })
        library.addCategoryItem("Network (Advanced)", message: "Send an API request.", .network, make: .node{
            BPAdvancedNetworkNode.make(on: $0)
        })
        
        library.addCategoryItem("If", message: "", .flow, make: .node(BPIfNode()))
        library.addCategoryItem("Repeat Count", message: "", .flow, make: .node(BPRepeatNode()))
        library.addCategoryItem("Sequence", message: "", .flow, make: .node(BPSequenceNode()))
        library.addCategoryItem("Switch", message: "", .flow, make: .node(BPSwitchNode()))
        library.addCategoryItem("Foreach", message: "", .flow, make: .node(BPForEachNode()))
        
        library.addCategoryItem("Print Log", message: "", .util, make: .node(BPPrintNode()))
        library.addCategoryItem("Print Text", message: "", .util, make: .node(BPPrintTextNode()))
        
        library.addCategoryItem("+", message: "Add two values together, or join two strings.", .math, make: .node(BPAdditionNode()))
        library.addCategoryItem("-", message: "Subtract a value from a base value.", .math, make: .node(BPSubtractNode()))
        library.addCategoryItem("×", message: "Multiply two values.", .math, make: .node(BPMultiplicationNode()))
        library.addCategoryItem("÷", message: "Divide a value by a value.", .math, make: .node(BPDivisionNode()))
        
        library.addCategoryItem("Not", message: "", .math, make: .node(BPNotNode()))
        library.addCategoryItem("Or", message: "", .math, make: .node(BPOrNode()))
        library.addCategoryItem("And", message: "", .math, make: .node(BPAndNode()))
        
        library.addCategoryItem("Witch", message: "", .flow, make: .node(BPTernaryExprNode()))
        
        library.addCategoryItem("Float to Int", message: "", .flow, make: .node(BPFloatToInt()))
        library.addCategoryItem("Int to Float", message: "", .flow, make: .node(BPIntToFloat()))
        library.addCategoryItem("String to Int", message: "", .flow, make: .node(BPStringToInt()))
        library.addCategoryItem("Int to String", message: "", .flow, make: .node(BPIntToString()))
        library.addCategoryItem("Float to String", message: "", .flow, make: .node(BPFloatToString()))
        
        library.addCategoryItem("Array Length", message: "", .util, make: .node(BPArrayLengthNode()))
        
        return library
    }()
    
    static let expressionLibrary: ACNodePickerLibrary = {
        let library = ACNodePickerLibrary()
        
        library.addCategoryItem("+", message: "Add two values together, or join two strings.", .math, make: .node(BPAdditionNode()))
        library.addCategoryItem("-", message: "Subtract a value from a base value.", .math, make: .node(BPSubtractNode()))
        library.addCategoryItem("×", message: "Multiply two values.", .math, make: .node(BPMultiplicationNode()))
        library.addCategoryItem("÷", message: "Divide a value by a value.", .math, make: .node(BPDivisionNode()))
        
        library.addCategoryItem("Not", message: "Message", .math, make: .node(BPNotNode()))
        library.addCategoryItem("Or", message: "Message", .math, make: .node(BPOrNode()))
        library.addCategoryItem("And", message: "Message", .math, make: .node(BPAndNode()))
        
        library.addCategoryItem("Witch", message: "Message", .flow, make: .node(BPTernaryExprNode()))
        
        library.addCategoryItem("Float to Int", message: "Message", .flow, make: .node(BPFloatToInt()))
        library.addCategoryItem("Int to Float", message: "Message", .flow, make: .node(BPIntToFloat()))
        library.addCategoryItem("String to Int", message: "Message", .flow, make: .node(BPStringToInt()))
        library.addCategoryItem("Int to String", message: "Message", .flow, make: .node(BPIntToString()))
        library.addCategoryItem("Float to String", message: "Message", .flow, make: .node(BPFloatToString()))

        return library
    }()
}


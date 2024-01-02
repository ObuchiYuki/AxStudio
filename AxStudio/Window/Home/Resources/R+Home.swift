//
//  R+Home.swift
//  AxComponents
//
//  Created by yuki on 2021/09/12.
//  Copyright © 2021 yuki. All rights reserved.
//

import AppKit

extension R {
    enum Home {
        enum Sidebar {
            static let recentDocument = Bundle.main.image(forResource: "sidebar/recent_document")!
            static let templeteLearrning = Bundle.main.image(forResource: "sidebar/templete_learning")!
            static let templeteApplication = Bundle.main.image(forResource: "sidebar/templete_application")!
            static let cloudDocument = Bundle.main.image(forResource: "sidebar/cloud_document")!
            static let localDocument = Bundle.main.image(forResource: "sidebar/local_document")!
            
            static let accountNoIcon = Bundle.main.image(forResource: "sidebar/acconut_noicon")!
            static let defaultProfile = NSImage(named: "sidebar/default_profile")!
        }
        
        enum Body {
            static let sideMargin: CGFloat = 32
            static let sideEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: sideMargin, bottom: 0, trailing: sideMargin)
            
            static let cloudDocumentDefaultThumbnail = Bundle.main.image(forResource: "body/cloud_document_default_thumb")!
            static let localDocumentDefaultThumbnail = Bundle.main.image(forResource: "body/local_document_default_thumb")!
            static let menuButton = Bundle.main.image(forResource: "body/menu_button")!
            static let cloudDocumentIcon = Bundle.main.image(forResource: "body/cloud_document_icon")!
            static let localDocumentIcon = Bundle.main.image(forResource: "body/local_document_icon")!
        }
    }
}

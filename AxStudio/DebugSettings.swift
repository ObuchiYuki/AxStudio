//
//  Settings.swift
//  AxStudio
//
//  Created by yuki on 2021/10/22.
//

#if DEBUG
/// デバッグ中に頻繁に設定を変更するものをここに集めている
enum DebugSettings {
    static let initialHomeViewModel = AxHomeViewModel.makeLocalhost()
    static let showDebugWindowOnLaunch = false
    static let randomIndicatorCellBackgroundColor = false
    static let hideLayoutOnAuto = false
    static let showDebugCell = true
    
    enum Load {
        static let showFragments = false
        static let selectFirstLayer = false
        static let showExpression = true
    }
}
#else
enum DebugSettings {
    static let initialHomeWindowPresenter = AxHomeWindowPresenter.makeProduction()
    static let showDebugWindowOnLaunch = false
    static let randomIndicatorCellBackgroundColor = false
    static let hideLayoutOnAuto = false
    static let showDebugCell = false
    
    enum Load {
        static let showFragments = false
        static let selectFirstLayer = false
        static let showExpression = false
    }
}
#endif

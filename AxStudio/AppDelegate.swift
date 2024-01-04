//
//  AppDelegate.swift
//  AxStudio
//
//  Created by yuki on 2021/09/10.
//

import AppKit
import SwiftEx
import AppKit
import DesignKit
import AxModelCore
import AxDocument
import AxComponents
import KeychainAccess
import Combine
import AxCommand
import LayoutEngine
import Neontetra
import BluePrintKit
import Lapix
import FigmaImport
import AxModel

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var groupItem: NSCustomKeyMenuItem!
    
    override init() {
        AxDocumentController.activate()
        AxLocalDocument.activate()
        AxDocumentPreviewManager.activate()

        FGBootstrap.load
        LPBootStrap.load
        AxCommandBootstrap.load
        BPColorAssetTable.load
        DKFontAssetTable.load
        ACFontLoader.load
        AxDocumentBootStrap.load
        
        AxModelFileManager.registerProxy(AxBuildinMediaFileProxy.default)
        
        AxDocument.onInitialized = { document in
            AxGeometoryNodeManager.initialize(document)
            AxFontManager.initialize(document)
            NEBootstrap.initialize(document)
            LELayoutObserver.initialize(document)
            AxCommandSync.initialize(document)
        }
        
        // 必要に応じて入れ替え
        AxHomeWindowController.currentViewModel = DebugSettings.initialHomeViewModel
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.groupItem.customKeyEquivalent = "g"
        self.groupItem.customkeyEquivalentModifierMask = .command
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first, url.scheme == "axstudio" {
            self.openURLScheme(url: url)
        } else {
            let assetURLs = urls.filter({ $0.pathExtension == "axasset" })
            let fileURLs = urls.filter({ $0.pathExtension == "axstudio" })
            
            guard !assetURLs.isEmpty || !fileURLs.isEmpty else {
                return ACToast(message: "AxStudio can't handle URLs", color: .systemYellow).show()
            }
            
            self.openAssetFiles(assetURLs)
        }
    }
    
    private func openAssetFiles(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        print(urls)
    }
    
    private func openURLScheme(url: URL) {
        guard let token = url.queryParamators["token"].flatMap({ $0 }) else { return }
        
        for homeWindowController in AxHomeWindowController.allInstantiatedControllers() {
            guard let viewModel = homeWindowController.chainObject as? AxHomeViewModel else {
                NSSound.beep()
                continue
            }
            
            viewModel.autoSigninPromise
                .sink{
                    guard let window = homeWindowController.window else { return }
                    viewModel.joinManager.joinDocument(token, window: window)
                }
        }
    }
}
 
final public class NSCustomKeyMenuItem: NSMenuItem {
    public var customKeyEquivalent: String?
    public var customkeyEquivalentModifierMask: NSEvent.ModifierFlags?
    
    public override var keyEquivalent: String {
        get { self.customKeyEquivalent ?? super.keyEquivalent }
        set { super.keyEquivalent = newValue }
    }
    public override var keyEquivalentModifierMask: NSEvent.ModifierFlags {
        get { self.customkeyEquivalentModifierMask ?? super.keyEquivalentModifierMask }
        set { super.keyEquivalentModifierMask = newValue }
    }
}

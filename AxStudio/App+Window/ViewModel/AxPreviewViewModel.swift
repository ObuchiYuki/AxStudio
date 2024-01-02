//
//  AxPreviewViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/12/31.
//

import SwiftEx
import AxComponents
import SwiftUIExporter
import iOSSimulatorKit
import AxDocument
import DesignKit
import ProjectKit

extension AxDocument {
    var tmpExportDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("preview_app")
            .appendingPathComponent(self.rootNode.id.compressedString().replacingOccurrences(of: "/", with: "_"))
    }
}

final class AxPreviewViewModel {
    private let window: NSWindow
    private var isPreviewExporting = false
    private let deviceListPromise = SIMSimulatorManager.standard.getDeviceList()
    private var objectBag = Set<AnyCancellable>()
    private var needsRebuild = true
    private var document: AxDocument!
    
    init(_ window: NSWindow) { self.window = window }
    
    func loadDocument(_ document: AxDocument) {
        self.document = document
    }
    
    func previewProject(_ sender: ACToolbarButton) {
        if self.isPreviewExporting { return }
        self.isPreviewExporting = true
        let oldImage = sender.image
        sender.image = nil
        let view = NSProgressIndicator()
        view.style = .spinning
        view.startAnimation(self)
        sender.addSubview(view)
        view.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(6)
        }
        
        buildProject()
            .flatMap{ $0.launch() }
            .receive(on: .main)
            .catch{ error in
                #if DEBUG
                ACToast.debugLog(message: error)
                #else
                ACToast.show(message: "Export Failed")
                #endif
            }
            .finally {
                self.isPreviewExporting = false
                sender.image = oldImage
                view.removeFromSuperview()
            }
    }
    
    private func clearCache() {
        let name = self.projectName()
        let path = document.tmpExportDirectory.appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            printIfDebug(error)
        }
    }
    
    private func projectName() -> String {
        let components = self.window.title.split(separator: ".")
        let name = String(components.first ?? "Untitled")
        return name
    }

    private func buildProject() -> Promise<SIMApplication, Error> {
        let projectName = self.projectName()
        
        return asyncHandler{[self] _await in
            let devicePromsie = self.matchingDevice(document)
            let projectPromise = SwiftUIExporter.exportProject(document, projectName: projectName, usage: .preview)
            
            let (device, project) = try _await | devicePromsie.combine(projectPromise)
            let result = try PKProjectExporter.exportProject(project, format: false, to: document.tmpExportDirectory)
            
            let application = SIMApplication(bundleID: result.bundleID, device: device)
            try _await | application.build(result.projectURL, target: result.appTarget)
            return application
        }
    }
    
    private func matchingDevice(_ document: AxDocument) -> Promise<SIMSimulatorDevice, Error> {
        asyncHandler{[self] _await in
            let deviceList = try _await | deviceListPromise
            guard let version = deviceList.allVersions(of: .iOS).first(where: { $0.components[0] == 14 }) else {
                throw "No Device"
            }
            let devices = deviceList.iOSDevieces(of: .iPhone, version: version)
            let sizeClass = document.rootNode.appFile.screenSize.sizeClass
            
            let device = devices.first(where: { self.matchTypeIdentifier(sizeClass, identifier: $0.deviceData.deviceTypeIdentifier) }) ?? devices.last
            
            guard let matchDevice = device else { throw "No maching device" }
            
            return matchDevice
        }
    }
        
    private func matchTypeIdentifier(_ sizeClass: DKScreenClass, identifier: String?) -> Bool {
        switch sizeClass {
        case .iPhone11: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-11"
        case .iPhone8: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-8"
        case .iPhone8Plus: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus"
        case .iPhoneSE: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-SE--2nd-generation-"
        case .iPhone12Mini: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-12-mini"
        case .iPhone12: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-12"
        case .iPhone12Pro: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-12-Pro"
        case .iPhone12ProMax: return identifier == "com.apple.CoreSimulator.SimDeviceType.iPhone-12-Pro-Max"
        case .custom:
            return false
        }
    }
}


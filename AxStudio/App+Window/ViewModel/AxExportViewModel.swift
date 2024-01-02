//
//  AxExportViewModel.swift
//  AxStudio
//
//  Created by yuki on 2021/12/20.
//

import SwiftEx
import AxComponents
import SwiftUIExporter
import iOSSimulatorKit
import AxDocument
import DesignKit
import ProjectKit

final class AxExportViewModel {
    let window: NSWindow
    
    init(_ window: NSWindow) { self.window = window }
    
    
    private func projectName() -> String {
        let components = self.window.title.split(separator: ".")
        let name = String(components.first ?? "Untitled")
        return name
    }
    
    func exportProject() {
        guard let document = window.document else { return __warn_ifDebug_beep_otherwise() }
        let projectName = self.projectName()
        
        self.showInstruction {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            if panel.runModal() == .OK, let url = panel.url {
                SwiftUIExporter.exportProject(document, projectName: projectName, usage: .preview)
                    .tryMap{ project in
                        try PKProjectExporter.exportProject(project, format: true, to: url)
                    }
                    .peek{ result in
                        NSWorkspace.shared.open(result.projectURL)
                    }
                    .catch(document.handleError(_:))
            }
        }
    }
    
    private func showInstruction(_ callback: @escaping () -> ()) {
        if UserDefaults.standard.bool(forKey: "export.story") { return callback() }
        
        Story.xcodeTrust {[self] in
            Story.xcodeRun {
                UserDefaults.standard.set(true, forKey: "export.story")
                callback()
            }
            .show(on: window)
        }
        .show(on: window)
    }
}


private struct ACExportProgressProvider: ACFormProvider {
    
    let titleView = ACFormTitleView(title: "Exporting SwiftUI Code...")
    let progressView = ACFormProgressBarView()
    
    func provideForm(into panel: ACFormPanel) {
        panel.addFormView(titleView)
        panel.addFormView(progressView)
    }
}

//
//  AxLocalDocumentScreenShotManager.swift
//  AxStudio
//
//  Created by yuki on 2021/09/21.
//

import AxDocument
import AppKit
import LapixUI
import ZIPFoundation
import SwiftEx
import AppKit
import Promise

final class AxDocumentPreviewManager {
    
    public static let shared = AxDocumentPreviewManager()
    
    static func activate() { _ = self.shared }
    private var cloudPreviewMemo = [String: Promise<NSImage?, Never>]()
    private var localPreviewMemo = [URL: Promise<NSImage?, Never>]()
    
    func localPreview(for url: URL) -> Promise<NSImage?, Never>? {
        localPreviewMemo[url] ?? self.fetchLocalPreview(for: url) => { localPreviewMemo[url] = $0 }
    }
    func cloudPreview(for documentID: String) -> Promise<NSImage?, Never>? {
        cloudPreviewMemo[documentID] ?? self.loadCloudPreview(for: documentID) => { cloudPreviewMemo[documentID] = $0 }
    }
    
    private init() {
        self.observeLocalDocuments()
        self.observeCloudDocuments()
    }
    
    private func observeCloudDocuments() {
        NotificationCenter.default.addObserver(forName: AxCloudDocumentWindowManager.closeNotification, object: nil, queue: nil) { notice in
            guard let object = notice.object as? AxCloudDocumentWindowManager.NotificationObject else { return }
            guard let window = object.windowController.window, let image = self.takeScreenShot(of: window) else { return }
            let documentID = object.documentID
            
            self.saveCloudPreview(image, for: documentID)
            self.cloudPreviewMemo[documentID] = Promise.resolve(image)
        }
    }
    
    private func observeLocalDocuments() {
        NotificationCenter.default.addObserver(forName: AxLocalDocument.writeNotification, object: nil, queue: nil) { notice in
            guard let localDocument = notice.object as? AxLocalDocument, let window = localDocument.windowControllers.first?.window else { return }
            guard let image = self.takeScreenShot(of: window) else { return }
            
            localDocument.setPreviewImage(image)
            if let url = localDocument.fileURL {
                self.localPreviewMemo[url] = Promise.resolve(image)
            }
        }
    }
    
    private func saveCloudPreview(_ image: NSImage, for documentID: String) {
        let previewFileURL = self.cloudPreviewFileURL(documentID)
        
        DispatchQueue.global().async {
            try? image.png?.write(to: previewFileURL)
        }
    }
    
    private func loadCloudPreview(for documentID: String) -> Promise<NSImage?, Never>? {
        Promise.dispatch(on: .global()) { resolve, _ in
            let previewURL = self.cloudPreviewFileURL(documentID)
            resolve(NSImage(contentsOf: previewURL))
        }
        .receive(on: .main)
    }
    
    private func cloudPreviewFileURL(_ documentID: String) -> URL {
        enum __ { static let directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("previews") }
        try? FileManager.default.createDirectory(at: __.directory, withIntermediateDirectories: true, attributes: nil)
        let previewURL = __.directory.appendingPathComponent("\(documentID).png")
        return previewURL
    }
    
    private func fetchLocalPreview(for url: URL) -> Promise<NSImage?, Never>? {
        if url.pathExtension != "axstudio" { return nil }
        guard let archive = try? Archive(url: url, accessMode: .read, pathEncoding: nil) else { return nil }
        guard let previewFile = archive["preview.png"] else { return nil }
        
        return Promise.dispatch(on: .global()){ resolve, _ in
            let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().base64String)
            _ = try? archive.extract(previewFile, to: tmpURL)
            let image = NSImage(contentsOf: tmpURL)
            resolve(image)
        }
        .receive(on: .main)
    }
    
    private func takeScreenShot(of window: NSWindow) -> NSImage? {
        var targetView: LPCanvasView?
        window.contentViewController?.view.scan{ view in
            if let canvasView = view as? LPCanvasView { targetView = canvasView }
        }
        guard let imageView = targetView, let cgImage = imageView.currentImageRepresentation() else { return nil }
        
        return NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
    }
}

extension NSView {
    public func scan(_ body: (NSView) -> ()) {
        body(self)
        for subview in self.subviews { subview.scan(body) }
    }
}


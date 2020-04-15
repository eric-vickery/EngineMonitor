//
//  Logger.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/31/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import Foundation

class Logger {
    
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    func setup() -> Void {
        // check for container existence
        if let url = self.containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func writeToLog() {
        let myDocumentUrl = self.containerUrl?
            .appendingPathComponent("logs")
        .appendingPathComponent("test")
        .appendingPathExtension("csv")
        
        "test".write(to: myDocumentUrl!, atomically: true, encoding: .utf8)
    }
}

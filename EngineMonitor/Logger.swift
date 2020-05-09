//
//  Logger.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/31/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import Foundation

class Logger {
    static let sharedInstance = Logger()
    
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("EngineMonitor")
    }
    
    var logFileUrl: URL
    var dateFormatter = DateFormatter()
    
    init() {
        // Dummy Initializer here. Gets actually initialized in createLogFileIfNotExists
        self.logFileUrl = URL(fileURLWithPath: "")
        
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        // check for container existence
        if let url = self.containerUrl {
            if !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            
            createLogFileIfNotExists()
        }
    }
    
    func createLogFileIfNotExists() {
        let logFileName = getLogFileName()
        if let logFileUrl = self.containerUrl?.appendingPathComponent(logFileName)
        {
            self.logFileUrl = logFileUrl
            if !FileManager.default.fileExists(atPath: self.logFileUrl.path, isDirectory: nil) {
                do {
                    try "Avidyne Engine Data Log   This is Eric's format - not an actual Avidyne. Reach me at eric@fiedlervickery.com\n".write(to: self.logFileUrl, atomically: true, encoding: .utf8)
                }
                catch {
                    print(error.localizedDescription)
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss"
                writeToLog(dateFormatter.string(from: Date()) + "\n")
                writeToLog( "\"TIME\",\"LAT\",\"LON\",\"PALT\",\"E1\",\"E2\",\"E3\",\"E4\",\"C1\",\"C2\",\"C3\",\"C4\",\"OILT\",\"OILP\",\"RPM\",\"OAT\",\"MAP\",\"FF\",\"USED\",\"AMPL\",\"AMPR\",\"LBUS\",\"RBUS\",\"TIT\"\n")
            }
        }
    }
    
    func getLogFileName() -> String {
        dateFormatter.dateFormat = "yyy-MM-dd"
        return dateFormatter.string(from: Date()) + ".log"
    }
    
    func writeToLog(_ message: String) {
        do {
            let fileHandle = try FileHandle(forUpdating: self.logFileUrl)
            fileHandle.seekToEndOfFile()
            fileHandle.write(message.data(using: .utf8)!)
            fileHandle.closeFile()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func writeToLog(egt1: String, egt2: String, egt3: String, egt4: String, cht1: String, cht2: String, cht3: String, cht4: String, oilTemp: String, oilPressure: String,
                    rpm: String, oat: String, map: String, fuelFlow: String, voltage: String) {
        dateFormatter.dateFormat = "HH:mm:ss"
        let currentTime = dateFormatter.string(from: Date())
        let message = String(format: "%@,0,0,0,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,0,0,0,%@,0,0\n", currentTime, egt1, egt2, egt3, egt4, cht1, cht2, cht3, cht4, oilTemp, oilPressure, rpm, oat, map, fuelFlow, voltage)
        writeToLog(message)
    }
}

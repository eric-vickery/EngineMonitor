//
//  EngineData.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/3/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import Foundation
import Combine
import CocoaAsyncSocket

enum HealthStatus {
    case healthy
    case sick
    case dead
}

class EngineData: ObservableObject {
    @Published var currentValues:[String: Any] = [String: Any]()
    @Published var tach:Int = 0
    @Published var chtValues:[Int] = [0, 0, 0, 0]
    @Published var egtValues:[Int] = [0, 0, 0, 0]
    @Published var volts:Double = 0.0
    @Published var fuelFlow:Double = 0.0
    @Published var internalTemp:Int = 0
    @Published var outsideAirTemp:Int = 0
    @Published var oilTemp:Int = 0
    @Published var oilPressure:Int = 0
    @Published var fuelPressure:Int = 0
    @Published var leftTankLevel:Int = 0
    @Published var rightTankLevel:Int = 0
    @Published var manifoldPressure:Double = 0.0
    @Published var hourMeter:Double = 0.0
    @Published var fuelQuantity:Double = 0.0
    @Published var flightTime:String = ""
    @Published var endurance:String = ""
    @Published var healthStatus:HealthStatus = .dead
    
    private var dataLastReceivedTime = Date()
    private var dataLoastLoggedTime = Date()
    
    private var udpReceiver:UDPReceiver

    init(createTestData: Bool = false)
    {
        self.udpReceiver = UDPReceiver()
        self.udpReceiver.setEngineData(engineData: self)
        
        print("EngineData initialized")

        if createTestData {
            let byteArray:[UInt8] =
            [0x09, 0xD3, // Tach

            0x01, 0x73, // CHTs
            0x01, 0x90,
            0x01, 0x84,
            0x01, 0x8B,
            0x00, 0x4E,
            0x00, 0x4F,

            0x05, 0x34, // EGTs
            0x05, 0xAB,
            0x05, 0x66,
            0x05, 0x5E,
            0x00, 0x4E,
            0x00, 0x5C,

            0x00, 0x06, // Aux5
            0x00, 0x00, // Aux6

            0x00, 0x00, // Airspeed
            0x00, 0x00, // Altitude

            0x00, 0x8E, // Volts (0.1)

            0x00, 0x72, // Fuel Flow (0.1 GPH)

            0x56, // Internal Temp
            0xCE, // Carb Temp
            0x00, // Vertical Speed

            0x71, // OAT unsigned 8bit with offset of +50 added

            0x00, 0xC9, // Oil Temp Range 59-314 deg F
            0x4A, // Oil Pressure

            0x00, 0x09, // Aux1
            0x00, 0x0C, // Aux2
            0x00, 0x0F, // Aux3
            0x00, 0xF0, // Aux4

            0x00, 0x3B, // Coolant Temp

            0x01, 0x0F, // Hour Meter (0.1)

            0x00, 0x00, // Fuel Quantity (0.1 gallons)

            0x00, // Flight Time Hours
            0x18, // Flight Time Minutes
            0x1C, // Flight Time Seconds
            0x00, // Endurance Hours
            0x00, // Endurance Minutes

            0x00, 0x00, // Baro (0.01)
            0x00, 0x00, // Tach2
            0x6C, // Spare
            0x62]
            parseData(data: Data(byteArray))
        }
    }
    
    deinit {
        print("EngineData going away")
    }
    
    func startData()
    {
        print("EngineData startData()")
        let sock = GCDAsyncUdpSocket(delegate: self.udpReceiver, delegateQueue: DispatchQueue.main)

        do {
            try sock.bind(toPort: 6969)
            try sock.enableBroadcast(true)
            try sock.beginReceiving()
        }
        catch
        {
            print("Error setting up UDP")
        }
        
        let _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            let interval = self.dataLastReceivedTime.timeIntervalSinceNow
            if (self.healthStatus == .healthy || self.healthStatus == .sick) && interval < -10 {
                self.healthStatus = .dead
            } else if self.healthStatus == .healthy && interval < -2 {
                self.healthStatus = .sick
            }
            self.currentValues["health"] = self.healthStatus
        }
    }
    
    func parseData(data: Data)
    {
        if data.count != 70 {
            // Bad data
            print("Bad data, count was \(data.count)")
            return
        }
        
        self.tach = Int(data[0]) << 8 | Int(data[1])
        self.currentValues["tach"] = self.tach
        for index in stride(from: 0, through: 6, by: 2) {
            self.chtValues[index/2] = Int(data[2+index]) << 8 | Int(data[3+index])
        }
        for index in stride(from: 0, through: 6, by: 2) {
            self.egtValues[index/2] = Int(data[14+index]) << 8 | Int(data[15+index])
        }
        self.currentValues["cylinderTemps"] = (self.chtValues, self.egtValues)
        self.volts = Double(Int(data[34]) << 8 | Int(data[35])) / 10.0
        self.currentValues["volts"] = self.volts
        self.fuelFlow = Double(Int(data[36]) << 8 | Int(data[37])) / 10.0
        self.currentValues["fuelFlow"] = self.fuelFlow
        self.internalTemp = Int(data[38])
        self.currentValues["internalTemp"] = self.internalTemp
        self.outsideAirTemp = Int(Int8(data[41]))
        self.currentValues["outsideAirTemp"] = self.outsideAirTemp
        self.oilTemp = Int(data[42]) << 8 | Int(data[43])
        self.currentValues["oilTemp"] = self.oilTemp
        self.oilPressure = Int(data[44])
        self.currentValues["oilPressure"] = self.oilPressure
        self.fuelPressure = Int(data[45]) << 8 | Int(data[46])
        self.currentValues["fuelPressure"] = self.leftTankLevel
        self.leftTankLevel = Int(data[47]) << 8 | Int(data[48])
        self.currentValues["leftTankLevel"] = self.leftTankLevel
        self.rightTankLevel = Int(data[49]) << 8 | Int(data[50])
        self.currentValues["rightTankLevel"] = self.rightTankLevel
        self.manifoldPressure = Double(Int(data[51]) << 8 | Int(data[52])) / 10.0
        self.currentValues["manifoldPressure"] = self.manifoldPressure
        self.hourMeter = Double(Int(data[55]) << 8 | Int(data[56])) / 10
        self.currentValues["hourMeter"] = self.hourMeter
        self.fuelQuantity = Double(Int(data[57]) << 8 | Int(data[58])) / 10.0
        self.currentValues["fuelQuantity"] = self.fuelQuantity
        let flightTimeHours = Int(data[59])
        let flightTimeMinutes = Int(data[60])
        let flightTimeSeconds = Int(data[61])
        self.flightTime = String(format: "%d:%02d:%02d", flightTimeHours, flightTimeMinutes, flightTimeSeconds)
        self.currentValues["flightTime"] = self.flightTime
        let enduranceHours = Int(data[62])
        let enduranceMinutes = Int(data[63])
        self.endurance = String(format: "%d:%02d", enduranceHours, enduranceMinutes)
        self.currentValues["endurance"] = self.endurance
        
        self.dataLastReceivedTime = Date()
        self.healthStatus = .healthy
        self.currentValues["health"] = self.healthStatus
        
        // Only do logging every second
        if self.dataLoastLoggedTime.timeIntervalSinceNow < -1 && UserDefaults.standard.bool(forKey: "logging_enabled") {
            let egt1 = Helper.currentValueAsString(self.egtValues[0])
            let egt2 = Helper.currentValueAsString(self.egtValues[1])
            let egt3 = Helper.currentValueAsString(self.egtValues[2])
            let egt4 = Helper.currentValueAsString(self.egtValues[3])
            let cht1 = Helper.currentValueAsString(self.chtValues[0])
            let cht2 = Helper.currentValueAsString(self.chtValues[1])
            let cht3 = Helper.currentValueAsString(self.chtValues[2])
            let cht4 = Helper.currentValueAsString(self.chtValues[3])
            let oilTemp = Helper.currentValueAsString(self.oilTemp)
            let oilPressure = Helper.currentValueAsString(self.oilPressure)
            let rpm = Helper.currentValueAsString(self.tach)
            let oat = Helper.currentValueAsString(self.outsideAirTemp)
            let map = Helper.currentValueAsString(self.manifoldPressure)
            let fuelFlow = Helper.currentValueAsString(self.fuelFlow)
            let voltage = Helper.currentValueAsString(self.volts)

            Logger.sharedInstance.writeToLog(egt1: egt1, egt2: egt2, egt3: egt3, egt4: egt4, cht1: cht1, cht2: cht2, cht3: cht3, cht4: cht4, oilTemp: oilTemp, oilPressure: oilPressure, rpm: rpm, oat: oat, map: map, fuelFlow: fuelFlow, voltage: voltage)
            
            self.dataLoastLoggedTime = Date()
        }
    }
}

class UDPReceiver : NSObject, GCDAsyncUdpSocketDelegate {
    private var engineData: EngineData?
    
    func setEngineData(engineData: EngineData)
    {
        self.engineData = engineData
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?)
    {
        self.engineData!.parseData(data: data)
    }
}

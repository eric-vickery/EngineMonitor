//
//  ContentView.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 2/26/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
            VStack {
                HStack {
                    RoundGauge(label: "RPM", dataKey: "tach", maxValue: 2900, ranges: [Range(startingPercent: 0.01, endingPercent: 0.34, color: .yellow), Range(startingPercent: 0.34, endingPercent: 0.94, color: .green), Range(startingPercent: 0.94, endingPercent: 0.99, color: .red)])
                    RoundGauge(label: "MAN IN", dataKey: "manifoldPressure", maxValue: 35.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.86, color: .green), Range(startingPercent: 0.86, endingPercent: 0.99, color: .white)])
                }
                VStack(alignment: .leading) {
                    StraightGauge(label: "OIL PSI", dataKey: "oilPressure", maxValue: 100.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.15, color: .red), Range(startingPercent: 0.15, endingPercent: 0.5, color: .white), Range(startingPercent: 0.5, endingPercent: 0.90, color: .green), Range(startingPercent: 0.90, endingPercent: 0.99, color: .red)])
                    StraightGauge(label: "OIL TEMP", dataKey: "oilTemp", minValue: 60.0, maxValue: 250.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.42, color: .yellow), Range(startingPercent: 0.42, endingPercent: 0.80, color: .green), Range(startingPercent: 0.80, endingPercent: 0.97, color: .yellow), Range(startingPercent: 0.97, endingPercent: 0.99, color: .red)])
                    StraightGauge(label: "FUEL GPH", dataKey: "fuelFlow", maxValue: 16.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.9, color: .green), Range(startingPercent: 0.9, endingPercent: 0.99, color: .red)])
                    StraightGauge(label: "FUEL QTY", dataKey: "fuelQuantity", maxValue: 38.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.21, color: .red), Range(startingPercent: 0.21, endingPercent: 0.42, color: .yellow), Range(startingPercent: 0.42, endingPercent: 0.99, color: .green)])
                    StraightGauge(label: "VOLTS", dataKey: "volts", minValue: 12.0, maxValue: 16.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.2, color: .red), Range(startingPercent: 0.2, endingPercent: 0.6, color: .green), Range(startingPercent: 0.6, endingPercent: 0.75, color: .yellow), Range(startingPercent: 0.75, endingPercent: 0.99, color: .red)])
                }
                CHTEGTGauge(dataKey: "cylinderTemps", chtMaxValue: 500.0, egtMaxValue: 1600.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.30, color: .yellow), Range(startingPercent: 0.30, endingPercent: 0.84, color: .green), Range(startingPercent: 0.84, endingPercent: 0.95, color: .yellow), Range(startingPercent: 0.95, endingPercent: 0.99, color: .red)])
                HStack(spacing: 30) {
                    TextGauge(label: "FUEL PSI", dataKey: "fuelPressure")
                    TextGauge(label: "FLIGHT TIME", dataKey: "flightTime")
                    TextGauge(label: "OAT", dataKey: "outsideAirTemp")
                }
                HStack(spacing: 30) {
                    HealthGauge()
                    TextGauge(label: "ENDURANCE", dataKey: "endurance")
                    TextGauge(label: "HOBBS", dataKey: "hourMeter")
                }
                .padding(.top, 10)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(EngineData(createTestData: true))
    }
}

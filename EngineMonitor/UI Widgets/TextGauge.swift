//
//  TextGauge.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/4/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct TextGauge: View {
    var label = ""
    var dataKey = ""
    
    @EnvironmentObject var engineData: EngineData
    
    private let textOffset:CGFloat = -10
    
    var body: some View {
        VStack {
            Text(self.label)
                .bold()
                .foregroundColor(.white)
                .font(.body)
            Text(Helper.currentValueAsString(self.engineData.currentValues[self.dataKey]))
                .bold()
                .foregroundColor(.white)
                .font(.body)
        }
    }
}

struct TextGauge_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
        VStack(alignment: .leading) {
            TextGauge(label: "HOBBS", dataKey: "hourMeter")
            .environmentObject(EngineData(createTestData: true))
            TextGauge(label: "OAT", dataKey: "outsideAirTemp")
            .environmentObject(EngineData(createTestData: true))
            TextGauge(label: "ENDURANCE", dataKey: "endurance")
            .environmentObject(EngineData(createTestData: true))
            TextGauge(label: "FLIGHT TIME", dataKey: "flightTime")
            .environmentObject(EngineData(createTestData: true))
        })
    }
}

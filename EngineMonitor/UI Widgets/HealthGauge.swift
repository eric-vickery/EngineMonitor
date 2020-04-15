//
//  HealthGauge.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/4/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct HealthGauge: View {
    @EnvironmentObject var engineData: EngineData

    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Helper.getHealthStatusColorFromValue(self.engineData.currentValues["health"]))
                .frame(width: 20, height: 20, alignment: .center)
        }
    }
}

struct HealthGauge_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
            HealthGauge().environmentObject(EngineData(createTestData: true))
        )
    }
}

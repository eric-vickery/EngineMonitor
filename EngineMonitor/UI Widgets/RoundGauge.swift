//
//  RoundGauge.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/2/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct RoundGauge: View {
    var label = ""
    var dataKey = ""
    var minValue: CGFloat = 0
    var maxValue: CGFloat
    var ranges:[Range]

    @EnvironmentObject var engineData: EngineData

    var body: some View {
        ZStack(alignment: .trailing) {
            ZStack {
                BaseArc(startAngle: .degrees(-140), endAngle: .degrees(90), clockwise: true)
                .strokeBorder(Color.gray, lineWidth: 2)
                ForEach(0..<self.ranges.count) { index in
                    RangeArc(startingPercent: self.ranges[index].startingPercent, endingPercent: self.ranges[index].endingPercent)
                        .inset(by: 4.0)
                        .strokeBorder(self.ranges[index].color, lineWidth: 18)
                }
                DialValuePointer()
                    .fill(Color.white)
                    .rotationEffect(Angle(degrees: Double(230.0*(1.0-(Helper.currentValueAsPercent( self.engineData.currentValues[self.dataKey], min: self.minValue, max: self.maxValue)))) * -1.0))
            }
            .aspectRatio(contentMode: .fit)
            VStack(alignment: .trailing) {
            if self.label != "" {
                Text(self.label)
                .bold()
                .foregroundColor(.white)
                .font(.title)
                .padding(.trailing, 5)
                .offset(y: 40)
            }
            Text(Helper.currentValueAsString(self.engineData.currentValues[self.dataKey]))
            .bold()
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding(.trailing, 5)
            .offset(y: 40)
            }
        }
    }
}

struct RangeArc: InsettableShape {
    var startingPercent: CGFloat
    var endingPercent: CGFloat
    var startAngle: Angle = .degrees(130)
    var endAngle: Angle = .degrees(0)
    var clockwise: Bool = true
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let totalDegrees:CGFloat = 230.0
        let modifiedStart = startAngle + Angle(degrees: Double(totalDegrees * startingPercent))
        let modifiedEnd = startAngle + Angle(degrees: Double(totalDegrees * endingPercent))

        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
}

struct BaseArc: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
        
        return path
    }
}

struct DialValuePointer: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.midY-6))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY+6))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: 6, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}

struct RoundGauge_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
            RoundGauge(label: "RPM", dataKey: "tach", maxValue: 2900, ranges: [Range(startingPercent: 0.01, endingPercent: 0.34, color: .yellow), Range(startingPercent: 0.34, endingPercent: 0.93, color: .green), Range(startingPercent: 0.93, endingPercent: 0.99, color: .red)]))
        .environmentObject(EngineData(createTestData: true))
    }
}

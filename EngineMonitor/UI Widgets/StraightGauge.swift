//
//  StraightGauge.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/2/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct StraightGauge: View {
    var label = ""
    var dataKey = ""
    var minValue:CGFloat = 0
    var maxValue:CGFloat
    var ranges:[Range]
    var direction: Direction = .horizontal
    
    @EnvironmentObject var engineData: EngineData
    
    private let textOffset:CGFloat = -10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    if self.label != "" {
                    Text(self.label)
                        .bold()
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.leading, self.direction == .horizontal ? 20.0 : 0.0)
                        .frame(width: geometry.size.width*0.5, alignment: .leading)
                        .offset(y: self.textOffset - (geometry.size.height*0.05))
                    }
                Text(Helper.currentValueAsString(self.engineData.currentValues[self.dataKey]))
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.trailing, self.direction == .horizontal ? 20.0 : 0.0)
                    .frame(width: geometry.size.width*0.4, alignment: .trailing)
                    .offset(y: self.textOffset - (geometry.size.height*0.05))
                }
                .frame(alignment: .top)
                
                BaseLine(direction: self.direction)
                .strokeBorder(Color.gray, lineWidth: 2)
                ForEach(0..<self.ranges.count) { index in
                    RangeLine(startingPercent: self.ranges[index].startingPercent, endingPercent: self.ranges[index].endingPercent, direction: self.direction)
                        .strokeBorder(self.ranges[index].color, lineWidth: self.direction == .horizontal ? geometry.size.width*0.052 : geometry.size.height*0.052)
                }
                ValuePointer(direction: self.direction, currentPercent: Helper.currentValueAsPercent( self.engineData.currentValues[self.dataKey], min: self.minValue, max: self.maxValue))
                .fill(Color.white)
            }
        }
    }
}

struct RangeLine: InsettableShape {
    var startingPercent: CGFloat
    var endingPercent: CGFloat
    var insetAmount: CGFloat = 0
    var direction: Direction = .horizontal

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if self.direction == .horizontal {
            let offset = rect.height*0.05
            let totalX = rect.width*0.8
            let legLength = totalX*0.08
            let gapX = (rect.width - totalX)/2
            let startingX = (rect.minX + gapX) + (totalX*startingPercent)
            let endingX = (rect.minX + gapX) + (totalX*endingPercent)
            let highY = rect.midY + (legLength / 2) + offset
            
            path.move(to: CGPoint(x: startingX, y: highY))
            path.addLine(to: CGPoint(x: endingX, y: highY))
        }
        else {
            let totalY = rect.height*0.8
            let gapY = (rect.height - totalY)*0.2
            let startingY = (rect.maxY - gapY) - (totalY*startingPercent)
            let endingY = (rect.maxY - gapY) - (totalY*endingPercent)
            let midX = rect.midX - 1
            
            path.move(to: CGPoint(x: midX, y: startingY))
            path.addLine(to: CGPoint(x: midX, y: endingY))
        }

        return path
    }
}

struct BaseLine: InsettableShape {
    var insetAmount: CGFloat = 0
    var direction: Direction = .horizontal

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if self.direction == .horizontal {
            let offset = rect.height*0.05
            let totalX = rect.width*0.8
            let legLength = totalX*0.08
            let gapX = (rect.width - totalX)/2
            let startingX = rect.minX + gapX
            let endingX = rect.maxX - gapX
            let lowY = rect.midY + legLength + offset
            let highY = lowY - legLength

            path.move(to: CGPoint(x: startingX, y: highY))
            path.addLine(to: CGPoint(x: startingX, y: lowY))
            path.addLine(to: CGPoint(x: endingX, y: lowY))
            path.addLine(to: CGPoint(x: endingX, y: highY))
        }
        else {
            let totalY = rect.height*0.8
            let lowGapY = (rect.height - totalY)*0.2
            let highGapY = (rect.height - totalY)*0.8
            let startingY = rect.maxY - lowGapY
            let endingY = rect.minY + highGapY
            let sideHeight = totalY*0.08
            let lowX = rect.midX + sideHeight/2
            let highX = lowX - sideHeight
            
            path.move(to: CGPoint(x: highX, y: startingY))
            path.addLine(to: CGPoint(x: lowX, y: startingY))
            path.addLine(to: CGPoint(x: lowX, y: endingY))
            path.addLine(to: CGPoint(x: highX, y: endingY))
        }
        return path
    }
}

struct ValuePointer: InsettableShape {
    var insetAmount: CGFloat = 0
    var direction: Direction = .horizontal
    var currentPercent: CGFloat

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if self.direction == .horizontal {
            let offset = rect.height*0.05
            let totalX = rect.width*0.8
            let legLength = totalX*0.08
            let gapX = (rect.width - totalX)/2
            let startingX = (rect.minX + gapX) + (totalX*currentPercent)
            let lowX = startingX - 15
            let highX = startingX + 15
            let lowY = rect.midY + legLength + (offset*0.5)
            let highY = lowY - legLength

            path.move(to: CGPoint(x: startingX, y: lowY))
            path.addLine(to: CGPoint(x: lowX, y: highY))
            path.addLine(to: CGPoint(x: highX, y: highY))
            path.closeSubpath()
        }
        else {
//            let totalY = rect.height*0.8
//            let lowGapY = (rect.height - totalY)*0.2
//            let highGapY = (rect.height - totalY)*0.8
//            let startingY = rect.maxY - lowGapY
//            let endingY = rect.minY + highGapY
//            let sideHeight = totalY*0.08
//            let lowX = rect.midX + sideHeight/2
//            let highX = lowX - sideHeight
//
//            path.move(to: CGPoint(x: highX, y: startingY))
//            path.addLine(to: CGPoint(x: lowX, y: startingY))
//            path.addLine(to: CGPoint(x: lowX, y: endingY))
//            path.addLine(to: CGPoint(x: highX, y: endingY))
        }
        return path
    }
}

struct StraightGauge_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
        VStack(alignment: .leading) {
            StraightGauge(label: "FUEL GPH", dataKey: "fuelFlow", maxValue: 16.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.9, color: .green), Range(startingPercent: 0.9, endingPercent: 0.99, color: .red)])
            .environmentObject(EngineData(createTestData: true))
            StraightGauge(label: "OIL PSI", dataKey: "oilPressure", maxValue: 120.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.12, color: .red), Range(startingPercent: 0.12, endingPercent: 0.5, color: .yellow), Range(startingPercent: 0.5, endingPercent: 0.75, color: .green), Range(startingPercent: 0.75, endingPercent: 0.99, color: .red)])
            .environmentObject(EngineData(createTestData: true))
            StraightGauge(label: "OIL TEMP", dataKey: "oilTemp", minValue: 60.0, maxValue: 250.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.42, color: .yellow), Range(startingPercent: 0.42, endingPercent: 0.80, color: .green), Range(startingPercent: 0.80, endingPercent: 0.97, color: .yellow), Range(startingPercent: 0.97, endingPercent: 0.99, color: .red)])
            .environmentObject(EngineData(createTestData: true))
        })
    }
}

//
//  CHTEGTGauge.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/3/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

struct CHTEGTGauge: View {
    var label = ""
    var dataKey = ""
    var chtMinValue:CGFloat = 0
    var chtMaxValue:CGFloat
    var egtMinValue:CGFloat = 0
    var egtMaxValue:CGFloat
    var ranges:[Range]
    
    @EnvironmentObject var engineData: EngineData

    private let textOffset:CGFloat = -10
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                Text("CHT °F")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .offset(y: 15)
                    .padding(.leading, 10.0)
                    .frame(width: geometry.size.width*0.4, alignment: .leading)

                    Text("\(Helper.maxCylinderValueAsString(valueType: .CHT, value: self.engineData.currentValues[self.dataKey]))")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .offset(y: 15)
                    .frame(width: geometry.size.width*0.5, alignment: .trailing)
                }
                ZStack {
                    BorderLine()
                    .strokeBorder(Color.gray, lineWidth: 2)
                    ForEach(0..<self.ranges.count) { index in
                        CHTRangeLine(startingPercent: self.ranges[index].startingPercent, endingPercent: self.ranges[index].endingPercent)
                            .strokeBorder(self.ranges[index].color, lineWidth: geometry.size.height*0.05)
                    }
                    ForEach(0..<4) { index in
                        EGTBar(cylinderNum: index, currentPercent: Helper.currentCylinderValueAsCGFloat(cylinderIndex: index, valueType: .EGT, value: self.engineData.currentValues[self.dataKey])/self.egtMaxValue)
                        .fill(Color.green)
                    }
                    ForEach(0..<4) { index in
                        CHTPointer(cylinderNum: index, currentPercent: Helper.currentCylinderValueAsCGFloat(cylinderIndex: index, valueType: .CHT, value: self.engineData.currentValues[self.dataKey])/self.chtMaxValue)
                        .fill(Color.white)
                    }
                }
                HStack {
                    Text("EGT °F")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .offset(y: -10)
                    .padding(.leading, 10.0)
                    .frame(width: geometry.size.width*0.4, alignment: .leading)

                    Text("\(Helper.maxCylinderValueAsString(valueType: .EGT, value: self.engineData.currentValues[self.dataKey]))")
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .offset(y: -10)
                    .frame(width: geometry.size.width*0.5, alignment: .trailing)
                }
            }
            .padding([.leading, .trailing], 5)
        }
    }
}

struct CHTRangeLine: InsettableShape {
    var startingPercent: CGFloat
    var endingPercent: CGFloat
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let totalY = rect.height*0.99
        let gapY = (rect.height - totalY)*0.2
        let startingY = (rect.maxY - gapY) - (totalY*startingPercent)
        let endingY = (rect.maxY - gapY) - (totalY*endingPercent)
        let midX = rect.minX + 5 + (rect.height*0.025)
        
        path.move(to: CGPoint(x: midX, y: startingY))
        path.addLine(to: CGPoint(x: midX, y: endingY))

        return path
    }
}

struct BorderLine: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addRect(rect)

        return path
    }
}

struct CHTPointer: InsettableShape {
    var insetAmount: CGFloat = 0
    var cylinderNum:Int
    var currentPercent: CGFloat

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let totalX = rect.width*0.86
        let totalY = rect.height*0.99
        let offsetX = rect.width * 0.13
        let gapX = rect.width * 0.01
        let startingX = offsetX + gapX + ((totalX/4) * CGFloat(cylinderNum))
        let endingX = startingX + (totalX/4) - (gapX*2)
        let lowY = rect.maxY - (totalY * currentPercent) + 5
        let highY = lowY - 10

        path.move(to: CGPoint(x: startingX, y: lowY))
        path.addLine(to: CGPoint(x: endingX, y: lowY))
        path.addLine(to: CGPoint(x: endingX, y: highY))
        path.addLine(to: CGPoint(x: startingX, y: highY))
        path.closeSubpath()

        return path
    }
}

struct EGTBar: InsettableShape {
    var cylinderNum:Int
    var currentPercent: CGFloat
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let totalX = rect.width*0.86
        let totalY = rect.height*0.99
        let offsetX = rect.width * 0.13
        let gapX = rect.width * 0.03
        let startingX = offsetX + gapX + ((totalX/4) * CGFloat(cylinderNum))
        let endingX = startingX + (totalX/4) - (gapX*2)
        let lowY = rect.maxY - (rect.height * 0.01)
        let highY = lowY - (totalY * currentPercent)

        path.move(to: CGPoint(x: startingX, y: lowY))
        path.addLine(to: CGPoint(x: startingX, y: highY))
        path.addLine(to: CGPoint(x: endingX, y: highY))
        path.addLine(to: CGPoint(x: endingX, y: lowY))
        path.closeSubpath()

        return path
    }
}

struct CHTEGTGauge_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
        .edgesIgnoringSafeArea(.vertical)
        .overlay(
            CHTEGTGauge(dataKey: "cylinderTemps", chtMaxValue: 500.0, egtMaxValue: 1600.0, ranges: [Range(startingPercent: 0.01, endingPercent: 0.30, color: .yellow), Range(startingPercent: 0.30, endingPercent: 0.84, color: .green), Range(startingPercent: 0.84, endingPercent: 0.96, color: .yellow), Range(startingPercent: 0.96, endingPercent: 0.99, color: .red)]).environmentObject(EngineData(createTestData: true))
        )
    }
}

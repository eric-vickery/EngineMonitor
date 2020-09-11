//
//  Helpers.swift
//  EngineMonitor
//
//  Created by Eric Vickery on 3/2/20.
//  Copyright © 2020 Eric Vickery. All rights reserved.
//

import SwiftUI

class Helper
{
    static func currentValueAsString(_ value: Any?, ignoreZero: Bool = false) -> String
    {
        var valueString = ""
        
        if let value = value as? Double {
            valueString = String(format: "%.1f", value)
        }
        else if let value = value as? Int {
            valueString = String(format: "%d", value)
        }
        else if let value = value as? String {
            valueString = value
        }
        
        if valueString == "0" && ignoreZero {
            valueString = ""
        }

        return valueString
    }
    
    static func currentValueAsCGFloat(_ value: Any?) -> CGFloat
    {
        var valueFloat:CGFloat = 0.0
        
        if let value = value as? Double {
            valueFloat = CGFloat(value)
        }
        else if let value = value as? Int {
            valueFloat = CGFloat(value)
        }
        
        return valueFloat
    }

    static func currentValueAsPercent(_ value: Any?, min: CGFloat, max: CGFloat) -> CGFloat
    {
        let valueFloat = currentValueAsCGFloat(value)
        
        var percent = (valueFloat - min)/(max - min)

        if percent < 0.0 {
            percent = 0.0
        }
        if percent > 1.0 {
            percent = 1.0
        }
        return percent
    }

    static func currentCylinderValueOrDeltaAsString(cylinderIndex: Int, valueType: CylinderValueType, value: Any?) -> String
    {
        if let value = value as? ([CylinderValues], [CylinderValues]) {
            return currentValueAsString((valueType == .CHT ? value.0 : value.1)[cylinderIndex].currentValueOrDelta)
        }
        
        return ""
    }
    
    static func currentCylinderValueAsString(cylinderIndex: Int, valueType: CylinderValueType, value: Any?) -> String
    {
        if let value = value as? ([CylinderValues], [CylinderValues]) {
            return currentValueAsString((valueType == .CHT ? value.0 : value.1)[cylinderIndex].currentValue)
        }
        
        return ""
    }
    
    static func currentCylinderValueAsCGFloat(cylinderIndex: Int, valueType: CylinderValueType, value: Any?) -> CGFloat
    {
        if let value = value as? ([CylinderValues], [CylinderValues]) {
            return currentValueAsCGFloat((valueType == .CHT ? value.0 : value.1)[cylinderIndex].currentValue)
        }
        
        return 0.0
    }
    
    static func maxCylinderValueAsString(valueType: CylinderValueType, value: Any?) -> String
    {
        if let value = value as? ([CylinderValues], [CylinderValues]) {
            if valueType == .CHT {
                return currentValueAsString(value.0.max()?.currentValue)
            }
            else {
                return currentValueAsString(value.1.max()?.currentValue)
            }
        }
        
        return ""
    }
    
    static func currentCylinderLeanNumberAsString(cylinderIndex: Int, valueType: CylinderValueType, value: Any?) -> String
    {
        if let value = value as? ([CylinderValues], [CylinderValues]) {
            return currentValueAsString((valueType == .CHT ? value.0 : value.1)[cylinderIndex].peakedNum, ignoreZero: true)
        }
        
        return ""
    }
    
    static func getHealthStatusColorFromValue(_ value: Any?) -> Color
    {
        if let value = value as? HealthStatus {
            switch value
            {
            case .healthy:
                return Color.green
            case .sick:
                return Color.yellow
            case .dead:
                return Color.red
            }
        }
        return Color.red
    }
}

struct Range {
    var startingPercent:CGFloat
    var endingPercent:CGFloat
    var color:Color
}

enum Direction {
    case horizontal
    case vertical
}

enum CylinderValueType {
    case CHT
    case EGT
}

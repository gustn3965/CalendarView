//
//  CalendarType.swift
//  WeatherMood
//
//  Created by hyunsu on 2021/08/08.
//

import Foundation

enum CalendarType: Int {
    case month = 6
    case week = 1
    
    var numberOfRows: Int {
        rawValue
    }
    
    var numberOfCellInPage: Int {
        switch self {
        case .month:
            return 42
        case .week:
            return 7
        }
    }
}

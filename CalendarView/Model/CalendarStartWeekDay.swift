//
//  CalendarStartWeekDay.swift
//  WeatherMood
//
//  Created by hyunsu on 2021/08/08.
//

import Foundation

/// 시작하는 주의 첫번째를 월요일 또는 일요일로 갖는 객체다.
enum CalendarStartWeekDay: Int {
    case sunday = 1
    case monday = 2
    
    var offset: Int {
        rawValue
    }
}

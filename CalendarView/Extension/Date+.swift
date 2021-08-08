//
//  Date+.swift
//  CalendarView
//
//  Created by hyunsu on 2021/08/08.
//

import Foundation
extension Date {
    /// 일~월의경우 해당 Date가 속한 일~월 중 하나의 값을가져온다. ( 1부터 7까지 사이값 )
    func firstDayWeekday() -> Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// Date에서 *월1일로만 첫월의날짜만 가져온다.
    /// - Returns:  첫월의날짜의 옵셔널을 반환한다.
    func firstDayOfMonth() -> Date? {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.year, .month], from: self)
        let start: Date? = calendar.date(from: components)
        return start
    }
    
    /// 해당Date의 시간을 뺀, *년*월*일만 가져온다.
    func withoutTime() -> Date? {
        let components: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let start: Date? = Calendar.current.date(from: components)
        return start
    }
    
    /// 해당Date의 *일만 string으로 가져온다.
    func stringDay() -> String {
        String(Calendar.current.component(.day, from: self))
    }
    
    /// 해당Date의 *월만 string으로 가져온다.
    func stringMonth() -> String {
        String(Calendar.current.component(.month, from: self))
    }
    
    /// 해당Date의 *년만 string으로 가져온다.
    func stringYear() -> String {
        String(Calendar.current.component(.year, from: self))
    }
    
    /// from부터 Date날짜까지 월의 차이를 Int?로 가져온다. 6~9월은 3으로 반환된다.
    func months(from date: Date) -> Int? {
        Calendar.current.dateComponents([.month], from: date, to: self).month
    }
    
    /// 해당 Date의 한달 날짜개수를 반환한다.
    /// - Returns: 한달 날짜개수의 옵셔널을 반환한다.
    func numberOfDaysByMonth() -> Int? {
        let range: Range<Int>? = Calendar.current.range(of: .day, in: .month, for: self)
        return range?.count
    }

    /// 해당 Date의 한달날짜개수에서의 인덱스를 반환한다.
    /// - Returns: 인덱스의 옵셔널을 반환한다.
    ///
    /// 1일인경우 0을 반환한다.
    func indexByMonth() -> Int? {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        dateFormatter.timeZone = NSTimeZone.local
        let str: String = dateFormatter.string(from: self)
        guard let index = Int(str) else {
            return nil
        }
        return index - 1
    }
    
    /// 특정날짜만큼 지난 날짜를 반환한다.
    /// - Parameter offset: 이전, 이후 날짜만큼의 offset을 지정한다.
    /// - Returns: 지나거나 이전의 날짜의 옵셔널을 반환한다.
    ///
    /// offset이 1일경우 1일이후 날짜를 반환하고, offset이 -1인경우에 1일이전 날짜를 반환한다.
    func day(by offset: Int) -> Date? {
        let calendar: Calendar = Calendar.current
        let end: Date? = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: self))
        return end
    }
    
    func month(by offset: Int) -> Date? {
        var calendar: Calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end: Date? = Calendar.current.date(byAdding: .month, value: offset, to: calendar.startOfDay(for: self))
        return end
    }
}

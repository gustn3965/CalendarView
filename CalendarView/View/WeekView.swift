//
//  WeekView.swift
//  WeatherMood
//
//  Created by hyunsu on 2021/08/08.
//

import UIKit

/// 달력상단에 요일들을 나타내는 뷰다.
///
/// 월요일로 시작할지 일요일로 시작할지 파라미터를 받는다.
///
/// ```
/// let weekView = WeekView(startWeekDay: .sunday)
/// ```
class WeekView: UIStackView {
    private let dayOfWeek: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    var startWeekDay: CalendarStartWeekDay = .sunday

    convenience init(startWeekDay: CalendarStartWeekDay) {
        self.init(frame: .zero)
        self.startWeekDay = startWeekDay
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func makeWeek() -> [String] {
        switch startWeekDay {
        case .monday:
            var temp: [String] = dayOfWeek
            temp.append(temp.removeFirst())
            return temp
        case .sunday:
            return dayOfWeek
        }
    }

    func setupViews() {
        axis = .horizontal
        distribution = .fillEqually
        makeWeek().forEach {
            let label: UILabel = UILabel()
            label.textAlignment = .center
            label.textColor = .black
            if $0 == "SUN" {
                label.textColor = .red
            }
            label.text = $0
            addArrangedSubview(label)
        }
    }
}

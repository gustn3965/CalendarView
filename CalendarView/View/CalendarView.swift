//
//  CalendarView.swift
//  WeatherMood
//
//  Created by hyunsu on 2021/08/08.
//

import UIKit
/// CalendarView의 cellForItemAt을 구현하기 위한 프로토콜이다.
protocol CalendarViewDataSource: AnyObject {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, cellDate: CalendarView.CalendarDay?) -> UICollectionViewCell
}
/// CalendarView의 select를 구현하기 위한 프로토콜이다.
protocol CalendarViewDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
}

/// 수직 스택뷰로, monthLabel,  weekView, collectionView를 가지며, collectionView가 날짜들을 나타내는 캘린더뷰가 된다.
///
/// CalendarViewDataSource, CalednarViewDelegate를 채택하여 UICollectionView처럼 사용한다.
/// ```
/// let calendarView: CalendarView = CalendarView(type: .month, startWeekDay: .sunday)
/// ```
class CalendarView: UIStackView {
    // MARK: - Type
    typealias CalendarDay = (date: Date, isContainedInMonth: Bool)

    weak var calendarViewDataSource: CalendarViewDataSource?
    weak var calendarViewDelegate: CalendarViewDelegate?
    
    // MARK: - View
    var monthLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        return label
    }()
    var weekView: WeekView = WeekView()
    var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    // MARK: - Properties
    var type: CalendarType = CalendarType.month
    var startWeekDay: CalendarStartWeekDay = .sunday
    var indexPathDic: [Date: Set<IndexPath>] = [:]
    /// default로 오늘날 기준으로 -1000년 ~ 1000년까지 만들어낸다.
    var numberOfItemInCalendar: Int = 12 * 2_000 * 42
    /// indexPath범위에서 중간값을 가지며, 이는 오늘날짜와 근접한 indexPath가 되고, 처음에 여기로 스크롤해준다.
    lazy var todayIndexPath: IndexPath = IndexPath(item: numberOfItemInCalendar / 2, section: 0)
    
    // MARK: - init
    
    /// 캘린더뷰를 초기화하는 메서드다.
    /// - Parameters:
    ///   - type: 월간인지 주간인지를 지정한다.
    ///   - startWeekDay: 시작하는 주의 첫번째 요일을 월요일 또는 일요일로 정한다.
    convenience init(type: CalendarType = .month, startWeekDay: CalendarStartWeekDay = .sunday) {
        self.init(frame: .zero )
        self.startWeekDay = startWeekDay
        self.type = type
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        weekView = WeekView(startWeekDay: startWeekDay)
        addArrangedSubview(monthLabel)
        addArrangedSubview(weekView)
        addArrangedSubview(collectionView)
        axis = .vertical
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(setupLayout(by: type), animated: false)
    }
    
    private func setupLayout(by type: CalendarType) -> UICollectionViewLayout {
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth((1.0)), heightDimension: .fractionalHeight(1.0))
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
        
        let groupSize2: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((1.0)))
        let group2: NSCollectionLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize2, subitem: group, count: type.numberOfRows)
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group2)
        section.orthogonalScrollingBehavior = .paging
        section.visibleItemsInvalidationHandler = { [weak self] _, point, _ in
            self?.changeMonthLabel(point)
        }
        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - Convenience Method
extension CalendarView {
    /// 스크롤할때 해당 달의 날짜를 변경한다.
    private func changeMonthLabel(_ point: CGPoint ) {
        let contentsSize: CGFloat = collectionView.contentSize.width
        let page: CGFloat = point.x / contentsSize
        guard !(page.isNaN || page.isInfinite) else {
            return
        }
        guard let date: Date = calculateDateFrom(IndexPath(item: Int(page) * type.numberOfCellInPage + (type == .month ? 15 : 4), section: 0))?.date else {
            monthLabel.text = ""
            return
        }
        monthLabel.text = date.stringYear() + " " + date.stringMonth()
    }

    /// IndexPath를 통해서 Date를 알아낸다.
    ///
    /// todayIndexPath가 오늘날이 포함되는 주, 또는 달이된다. page는 하나의 frame 단위를 의미한다.
    ///
    /// 그러므로, 나누기 연산을 통해, todayIndexPath가 포함되는 page를 알 수 있고, 현재 indexPath가 포함되는 page알 수 있다.  그리고 indexPath에 해당하는 달의 첫번째 weekday를 구하여, 모듈러 연산을 통해, firstWeekDay로부터 offset만큼의 해당 날짜를 구할 수 있다.
    private func calculateDateFrom(_ indexPath: IndexPath) -> CalendarDay? {
        switch type {
        case .month:
            let todayPage: Int = todayIndexPath.item / type.numberOfCellInPage
            let indexPathPage: Int = indexPath.item / type.numberOfCellInPage
            
            guard let todayPageMonthDate: Date = Date().firstDayOfMonth(),
                  let indexPathPageMonthDate: Date = todayPageMonthDate.month(by: indexPathPage - todayPage) else {
                return nil
            }
            
            var indexPathPageFirstDayWeekday: Int = indexPathPageMonthDate.firstDayWeekday() - startWeekDay.rawValue
            indexPathPageFirstDayWeekday = indexPathPageFirstDayWeekday < 0 ? 6 : indexPathPageFirstDayWeekday
            let dist: Int = indexPath.item % type.numberOfCellInPage
            var isContainedInMonth: Bool = false
            
            guard let date: Date = indexPathPageMonthDate.day(by: dist - indexPathPageFirstDayWeekday),
                  let monthDist = date.firstDayOfMonth()?.months(from: indexPathPageMonthDate)
            else {
                return nil
            }
            indexPathDic[date, default: []].insert(indexPath)
            if monthDist == 0 {
                isContainedInMonth = true
            }
            return CalendarDay(date: date, isContainedInMonth: isContainedInMonth)
            
        case .week:
            guard let filteredTodayMonthDay = Date().withoutTime() else {
                return nil
            }
            var todayFirstDayWeek: Int = filteredTodayMonthDay.firstDayWeekday() - startWeekDay.rawValue
            todayFirstDayWeek = todayFirstDayWeek < 0 ? 6 : todayFirstDayWeek
            let todayIndexPathItem: Int = todayIndexPath.item % type.numberOfCellInPage
            let todayIndex: Int = todayIndexPath.item + (todayFirstDayWeek - todayIndexPathItem)
            
            guard let date: Date = Date().withoutTime()?.day(by: indexPath.item - todayIndex) else {
                return nil
            }
            indexPathDic[date, default: []].insert(indexPath)
            return CalendarDay(date: date, isContainedInMonth: true)
        }
    }
}

// MARK: - UICollectionViewDataSource, Delegate
extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItemInCalendar
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = calendarViewDataSource else {
            return UICollectionViewCell()
        }
        return dataSource.collectionView(collectionView, cellForItemAt: indexPath, cellDate: calculateDateFrom(indexPath))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension CalendarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        calendarViewDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        calendarViewDelegate?.collectionView(collectionView, didDeselectItemAt: indexPath)
    }
}

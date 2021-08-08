//
//  ViewController.swift
//  CalendarView
//
//  Created by hyunsu on 2021/08/08.
//

import UIKit

final class CalendarViewController: UIViewController {
    // MARK: - View
    var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let calendarView: CalendarView = {
        let calendarView: CalendarView = CalendarView(type: .month, startWeekDay: .sunday)
        calendarView.backgroundColor = .systemGray6
        calendarView.collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        return calendarView
    }()

    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.collectionView.scrollToItem(at: calendarView.todayIndexPath, at: .bottom, animated: false)
    }
    
    func setupViews() {
        stackView.addArrangedSubview(calendarView)
        view.backgroundColor = .white
        view.addSubview(stackView)
        calendarView.calendarViewDataSource = self
        calendarView.calendarViewDelegate = self
        
        let safeLayout: UILayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            [stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             stackView.topAnchor.constraint(equalTo: safeLayout.topAnchor, constant: 100),
             stackView.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor, constant: -100)])
    }
}

// MARK: - CalendarView DataSource, Delegate
extension CalendarViewController: CalendarViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, cellDate: CalendarView.CalendarDay?) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as? CalendarCell,
              let cellDate = cellDate else {
            return UICollectionViewCell() }
        cell.updateUIBy(cellDate.date, isContainedInMonth: cellDate.isContainedInMonth)
        return cell
    }
}

extension CalendarViewController: CalendarViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = calendarView.collectionView.cellForItem(at: indexPath) as? CalendarCell else {
            return
        }
        cell.contentView.backgroundColor = cell.contentView.backgroundColor == .red ? .white : .red
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = calendarView.collectionView.cellForItem(at: indexPath) as? CalendarCell else {
            return
        }
        cell.contentView.backgroundColor = .white
    }
}

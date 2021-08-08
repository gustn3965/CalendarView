//
//  CalendarCell.swift
//  WeatherMood
//
//  Created by hyunsu on 2021/08/08.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    var stackView: UIStackView = {
        let stack: UIStackView = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var dateLabel: UILabel = {
        let label: UILabel = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = " "
        label.textColor = .black
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func updateUIBy(_ date: Date, isContainedInMonth: Bool) {
        dateLabel.text = date.stringDay()
        dateLabel.textColor = isContainedInMonth ? .black : .white
        contentView.backgroundColor = isContainedInMonth ?.white : .systemGray2
    }
}

//
//  UIView+.swift
//  CalendarView
//
//  Created by hyunsu on 2021/08/08.
//

import UIKit.UIView
extension UIView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

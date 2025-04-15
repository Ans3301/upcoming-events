//
//  CustomCalendarView.swift
//  upcoming-events
//
//  Created by Мария Анисович on 18.03.2025.
//

import FSCalendar

protocol CustomCalendarViewDelegate: AnyObject {
    func didSelectDate(date: Date)
    func didSelectDateRange(startDate: Date, endDate: Date)
}

final class CustomCalendarView: FSCalendar {
    weak var customDelegate: CustomCalendarViewDelegate?
    
    private var startDate: Date?
    private var endDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.dataSource = self
        self.allowsMultipleSelection = true
        
        backgroundColor = .white
        
        appearance.headerTitleFont = UIFont(name: "Poppins-SemiBold", size: 20)
        appearance.headerTitleColor = UIColor(hexString: "#5856D6")

        appearance.weekdayTextColor = UIColor(hexString: "#3C3C434D", transparency: 0.3)
        appearance.weekdayFont = UIFont(name: "Poppins-SemiBold", size: 13)
        
        appearance.titleFont = UIFont(name: "Poppins-Regular", size: 18)
        appearance.titleDefaultColor = UIColor(hexString: "#5856D6")
        appearance.todayColor = .clear
        appearance.titleTodayColor = UIColor(hexString: "#5856D6")

        appearance.selectionColor = UIColor(hexString: "#5856D6")
        appearance.titleSelectionColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.addShadow()
    }

    private func addShadow() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 13
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 13).cgPath
        self.layer.shadowColor = UIColor(hexString: "#000000")?.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 30
    }
}

extension CustomCalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if self.startDate == nil {
            self.startDate = date
            calendar.select(date)
            self.customDelegate?.didSelectDate(date: date)
        } else if self.endDate == nil {
            if let start = startDate {
                if date > start {
                    self.endDate = date
                    self.selectRange(from: start, to: date)
                    if let end = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                        self.customDelegate?.didSelectDateRange(startDate: start, endDate: end)
                    }
                } else {
                    calendar.deselect(start)
                    self.startDate = date
                    self.customDelegate?.didSelectDate(date: date)
                }
            }
        } else {
            self.resetSelection()
            self.startDate = date
            calendar.select(date)
            self.customDelegate?.didSelectDate(date: date)
        }
    }
    
    private func selectRange(from startDate: Date, to endDate: Date) {
        var currentDate = startDate
        while currentDate <= endDate {
            self.select(currentDate)
            if let currDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = currDate
            }
        }
    }
        
    func resetSelection() {
        self.startDate = nil
        self.endDate = nil
        self.selectedDates.forEach { self.deselect($0) }
    }
}

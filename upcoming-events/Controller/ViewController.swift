//
//  ViewController.swift
//  upcoming-events
//
//  Created by Мария Анисович on 10.03.2025.
//

import EventKit
import SwifterSwift
import UIKit

final class ViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "My Events"
        label.font = UIFont(name: "Poppins-Medium", size: 34)
        label.textColor = .black
        return label
    }()
    
    private lazy var sharedEventsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitle("Shared\nEvents", for: .normal)
        button.setTitleColor(UIColor(hexString: "#5856D6"), for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)), for: .normal)
        button.tintColor = UIColor(hexString: "#5856D6")
        return button
    }()
 
    private var weekButton = PeriodButton()
    private var monthButton = PeriodButton()
    private var yearButton = PeriodButton()
    private var customButton = PeriodButton()
    private lazy var buttons = [weekButton, monthButton, yearButton, customButton]
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont(name: "Poppins-SemiBold", size: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var calendarView: CustomCalendarView = {
        let calendar = CustomCalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private var collectionView: UICollectionView!
    
    private var events: [EKEvent] = []
    private var timer: Timer?
    
    private var dateLabelTopConstraint: NSLayoutConstraint!
    private var collectionViewTopConstraint: NSLayoutConstraint!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupSharedEventsButton()
        setupAddButton()
        setupStackView()
        setupDateLabel()
        setupCollectionView()
        
        buttonTapped(weekButton)
    }
    
    private func fetchEvents(endOfPeriod: Date) {
        let today = Date()
        fetchEvents(startOfPeriod: today, endOfPeriod: endOfPeriod)
    }
    
    private func fetchEvents(startOfPeriod: Date, endOfPeriod: Date) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { granted, error in
            guard granted, error == nil else {
                print("Access to calendar denied or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let predicate = eventStore.predicateForEvents(withStart: startOfPeriod, end: endOfPeriod, calendars: nil)
            self.events = eventStore.events(matching: predicate)
            
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.startTimer()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimers), userInfo: nil, repeats: true)
    }
        
    @objc private func updateTimers() {
        collectionView.reloadData()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSharedEventsButton() {  
        view.addSubview(sharedEventsButton)
        
        NSLayoutConstraint.activate([
            sharedEventsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            sharedEventsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17)
        ])
        
        sharedEventsButton.addTarget(self, action: #selector(sharedEventsButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sharedEventsButtonTapped(_ button: UIButton) {
        let sharedEventsViewController = SharedEventsViewController()
        sharedEventsViewController.modalPresentationStyle = .overFullScreen
        sharedEventsViewController.modalTransitionStyle = .crossDissolve
        present(sharedEventsViewController, animated: true)
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17)
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped(_ button: UIButton) {
        let addEventViewController = AddEventViewController()
        addEventViewController.afterSave = { [weak self] message in
            if let self = self {
                self.showAlert(message: message)
                for b in self.buttons {
                    if b.isSelected {
                        self.buttonTapped(b)
                        break
                    }
                }
            }
        }
        present(addEventViewController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Adding Event", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupStackView() {
        weekButton.setTitle("Week", for: .normal)
        monthButton.setTitle("Month", for: .normal)
        yearButton.setTitle("Year", for: .normal)
        customButton.setTitle("Custom", for: .normal)
        
        weekButton.isSelected = true

        for button in buttons {
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
                
        stackView.addArrangedSubviews(buttons)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 117),
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    @objc private func buttonTapped(_ button: UIButton) {
        for b in buttons {
            if b !== button {
                b.isSelected = false
            }
        }
        
        let calendar = Calendar.current
        let today = Date()
        var endOfPeriod: Date?
        
        if button == customButton {
            dateLabelTopConstraint.constant = 585
            collectionViewTopConstraint.constant = 625
            
            dateLabel.layoutIfNeeded()
            collectionView.layoutIfNeeded()
            
            setupCalendarView()
            
            dateLabel.text = ""
            collectionView.isHidden = true
        } else {
            calendarView.resetSelection()
            calendarView.removeFromSuperview()
            
            dateLabelTopConstraint.constant = 189
            collectionViewTopConstraint.constant = 229
            
            dateLabel.layoutIfNeeded()
            collectionView.layoutIfNeeded()
            
            if button == weekButton {
                endOfPeriod = calendar.date(byAdding: .day, value: 7, to: today)
            } else if button == monthButton {
                endOfPeriod = calendar.date(byAdding: .month, value: 1, to: today)
            } else if button == yearButton {
                endOfPeriod = calendar.date(byAdding: .year, value: 1, to: today)
            }
            
            if let end = endOfPeriod {
                fetchEvents(endOfPeriod: end)
                dateLabel.text = formattedDateRange(from: today, to: end)
            }
        }
    }
    
    private func formattedDateRange(from startDate: Date, to endDate: Date) -> String {
        let monthDayYearFormatter = DateFormatter()
        monthDayYearFormatter.dateFormat = "MMM d, yyyy"

        let startDateString = formattedDate(date: startDate)
        let endDateString = formattedDate(date: endDate)

        return "\(startDateString) - \(endDateString)"
    }
    
    private func formattedDate(date: Date) -> String {
        let monthDayYearFormatter = DateFormatter()
        monthDayYearFormatter.dateFormat = "MMM d, yyyy"
        return monthDayYearFormatter.string(from: date)
    }
    
    private func setupDateLabel() {
        view.addSubview(dateLabel)
        
        dateLabelTopConstraint = dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 189)

        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            dateLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            dateLabelTopConstraint
        ])
    }
    
    private func setupCalendarView() {
        calendarView.customDelegate = self
        
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 181),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 380)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 8

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: "eventCollectionViewCell")
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 229)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewTopConstraint
        ])
    }
    
    deinit {
        timer?.invalidate()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCollectionViewCell", for: indexPath) as? EventCollectionViewCell else {
            fatalError("Unable to dequeue eventCollectionViewCell")
        }
        cell.configure(text: events[indexPath.item].title, remainingTime: getRemainingTime(event: events[indexPath.item]))
        return cell
    }
    
    private func getRemainingTime(event: EKEvent) -> String {
        let timeInterval = event.startDate.timeIntervalSinceNow
        
        if timeInterval <= 0 {
            return "Started"
        } else {
            return formatTimeInterval(interval: timeInterval)
        }
    }
    
    private func formatTimeInterval(interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        let totalHours = totalMinutes / 60
        let days = totalHours / 24
        let hours = totalHours % 24
        let minutes = totalMinutes % 60
                
        if days > 0 {
            return days < 5 ? "\(days) d \(hours)h" : "\(days) days"
        } else if hours > 0 {
            return minutes > 0 ? "\(hours) h \(minutes)m" : "\(hours) hours"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "Less than a minute"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shareEventViewController = ShareEventViewController()
        shareEventViewController.event = SharedEvent(title: events[indexPath.item].title, date: events[indexPath.item].startDate)
        present(shareEventViewController, animated: true)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(view.frame.width - 32, 48)
    }
}

extension ViewController: CustomCalendarViewDelegate {
    func didSelectDate(date: Date) {
        let calendar = Calendar.current
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: date)
        if let end = endOfDay {
            fetchEvents(startOfPeriod: date, endOfPeriod: end)
            dateLabel.text = formattedDate(date: date)
        }
    }
    
    func didSelectDateRange(startDate: Date, endDate: Date) {
        fetchEvents(startOfPeriod: startDate, endOfPeriod: endDate)
        dateLabel.text = formattedDateRange(from: startDate, to: endDate)
    }
}

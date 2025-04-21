//
//  AddEventViewController.swift
//  upcoming-events
//
//  Created by Мария Анисович on 25.03.2025.
//

import EventKit
import UIKit

final class AddEventViewController: UIViewController {
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
        return navigationBar
    }()
    
    private lazy var enterView: InputView = {
        let view = InputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var afterSave: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupEnterView()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let navItem = UINavigationItem(title: "New Event")
        let leftButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let rightButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        rightButton.isEnabled = false
        
        navItem.leftBarButtonItem = leftButton
        navItem.rightBarButtonItem = rightButton
         
        navigationBar.setItems([navItem], animated: false)
    }
    
    @objc private func cancelButtonTapped(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped(_ button: UIButton) {
        guard let title = enterView.getTitle() else {
            return
        }
        
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = enterView.getDate()
        let secondsInHour = 3600.0
        event.endDate = event.startDate.addingTimeInterval(secondsInHour)
        event.calendar = eventStore.defaultCalendarForNewEvents
            
        eventStore.requestAccess(to: .event) { granted, error in
            guard granted, error == nil else {
                print("Access to calendar denied or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
                
            var message: String
            do {
                try eventStore.save(event, span: .thisEvent)
                message = "Event added successfully"
            } catch {
                message = "Failed to save event: \(error)"
            }
                
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.afterSave?(message)
                }
            }
        }
    }
    
    private func setupEnterView() {
        enterView.addTextFieldTarget(nil, action: #selector(editingChanged(_:)))
        
        view.addSubview(enterView)
        
        NSLayoutConstraint.activate([
            enterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            enterView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            enterView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.18)
        ])
    }
    
    @objc private func editingChanged(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        navigationBar.items?.first?.rightBarButtonItem?.isEnabled = !text.isEmpty
    }
}

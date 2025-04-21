//
//  SharedEventsStorage.swift
//  upcoming-events
//
//  Created by Мария Анисович on 01.04.2025.
//

import UIKit

final class SharedEventsStorage {
    private static let key = "sharedEvents"

    static func saveEvent(_ event: SharedEvent) {
        var events = loadEvents()
        events.append(event)
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func loadEvents() -> [SharedEvent] {
        if let data = UserDefaults.standard.data(forKey: key),
           let events = try? JSONDecoder().decode([SharedEvent].self, from: data)
        {
            return events
        }
        return []
    }
    
    static func deleteEvent(_ event: SharedEvent) {
        var events = loadEvents()
        if let index = events.firstIndex(of: event) {
            events.remove(at: index)
            if let data = try? JSONEncoder().encode(events) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}

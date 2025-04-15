//
//  SharedEvent.swift
//  upcoming-events
//
//  Created by Мария Анисович on 27.03.2025.
//

import UIKit

struct SharedEvent: Codable, Equatable {
    let title: String
    let date: Date
    
    func encodeToString() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(self) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    static func decodeFromString(_ encodedString: String) -> SharedEvent? {
        if let data = Data(base64Encoded: encodedString) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try? decoder.decode(SharedEvent.self, from: data)
        }
        return nil
    }
}

//
//  Event.swift
//  EventScheduler
//
//  Created by Aryan Rai on 08/08/24.
//

import SwiftUI
import FirebaseFirestore

enum EventColor: Codable, CaseIterable {
    case red
    case green
    case yellow
    case purple
    case blue
    var value: Color {
        switch self {
        case .red:
            Color.eventRed
        case .green:
            Color.eventGreen
        case .yellow:
            Color.eventYellow
        case .purple:
            Color.eventPurple
        case .blue:
            Color.eventBlue
        }
    }
}

struct Event: Identifiable, Codable, Hashable  {
    @DocumentID var documentId: String?
    var id = UUID()
    var title: String
    var starts: Date
    var ends: Date
    var color: EventColor
    
    var isAllDay: Bool {
        let startOfDay = Calendar.current.startOfDay(for: starts)
        let endOfDay = Calendar.current.date(byAdding: .minute, value: -1, to: Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!)!
        return startOfDay == starts && endOfDay == ends
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

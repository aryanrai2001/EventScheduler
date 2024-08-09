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

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var starts: Date
    var ends: Date
    var color: EventColor
}

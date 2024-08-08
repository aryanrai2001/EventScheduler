//
//  Event.swift
//  EventScheduler
//
//  Created by Aryan Rai on 08/08/24.
//

import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var startDate: Date
    var endDate: Date
}

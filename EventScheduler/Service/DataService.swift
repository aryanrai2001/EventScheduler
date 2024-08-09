//
//  DataService.swift
//  EventScheduler
//
//  Created by Aryan Rai on 09/08/24.
//

import SwiftUI
import FirebaseFirestore

final class DataService: ObservableObject {
    
    static let shared = DataService()
    private init() {}
    
    private var eventListenerRegistration: ListenerRegistration?
    
    func createNewEvent(event: Event) async throws -> String {
        let eventDocument = Firestore.firestore().collection("events").document()
        try eventDocument.setData(from: event)
        return eventDocument.documentID
    }
    
    func addListenerForEvent(date: Date, completion: @escaping (_ events: [Event]) -> Void) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        eventListenerRegistration?.remove()
        eventListenerRegistration = Firestore.firestore().collection("events").whereField("starts", isLessThan: end).whereField("ends", isGreaterThan: start).addSnapshotListener{ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            let fetchedEvents: [Event] = documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Event.self)
            }
            var events = Set<Event>()
            for event in fetchedEvents {
                if event.starts > start && event.ends < end {
                    events.insert(event)
                } else if event.starts <= st{
                    
                }
            }
            completion(events.sorted(by: { event1, event2 in
                event1.starts < event2.starts
            }))
        }
    }
}

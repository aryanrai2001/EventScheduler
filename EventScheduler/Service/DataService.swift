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
    
    private func sliceEvent(event: Event, from: Date) -> (Event, Event) {
        var firstEvent = event
        var secondEvent = event
        
        firstEvent.ends = Calendar.current.date(byAdding: .minute, value: -1, to: from)!
        secondEvent.starts = from
        
        return (firstEvent, secondEvent)
    }
    
    private func extractDates(from start: Date, to end: Date) -> [Date] {
        let startDate = Calendar.current.startOfDay(for: start)
        let endDate = Calendar.current.startOfDay(for: end)
        var currentDate = startDate
        
        var dates: [Date] = []
        
        while currentDate < endDate {
            dates.append(currentDate)
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
    
    func createNewEvent(event: Event) async throws {
        let days = extractDates(from: event.starts, to: event.ends)
        var events = [Event]()
        var currEvent = event
        
        for day in days {
            let end = Calendar.current.date(byAdding: .day, value: 1, to: day)!
            let (firstEvent, secondEvent) = self.sliceEvent(event: currEvent, from: end)
            events.append(firstEvent)
            currEvent = secondEvent
        }
        
        events.append(currEvent)
        
        for quantizedEvent in events {
            let eventDocument = Firestore.firestore().collection("events").document()
            try eventDocument.setData(from: quantizedEvent)
        }
    }
    
    func deleteEvent(eventId: UUID) async throws {
        let collection = Firestore.firestore().collection("events")
        if let querySnapshot = try? await collection.whereField("id", isEqualTo: eventId.uuidString).getDocuments() {
            for document in querySnapshot.documents {
                try await document.reference.delete()
            }
        }
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
            completion(fetchedEvents)
        }
    }
}

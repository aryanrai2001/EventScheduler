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
    private var allDayEventListenerRegistration: ListenerRegistration?
    
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
        eventListenerRegistration = Firestore.firestore().collection("events").whereField("starts", isGreaterThan: start).whereField("ends", isLessThan: end).addSnapshotListener{ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            let events: [Event] = documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Event.self)
            }
            completion(events)
        }
    }
    
    func addListenerForAllDayEvent(date: Date, completion: @escaping (_ events: [Event]) -> Void) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        allDayEventListenerRegistration?.remove()
        allDayEventListenerRegistration = Firestore.firestore().collection("events").whereField("starts", isLessThan: start).whereField("ends", isGreaterThan: end).addSnapshotListener{ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            let events: [Event] = documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Event.self)
            }
            completion(events)
        }
    }
}

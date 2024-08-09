//
//  AddNewEvent.swift
//  EventScheduler
//
//  Created by Aryan Rai on 09/08/24.
//

import SwiftUI

struct AddNewEvent: View {

    @Binding var showAddEventForm: Bool
    
    @State private var title: String = ""
    @State private var starts: Date = Date.now
    @State private var ends: Date = Date.now
    @State private var color: EventColor = .red
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title", text: $title)
                    HStack {
                        Text("Color")
                        Spacer()
                        HStack(spacing: 15) {
                            ForEach(EventColor.allCases, id:\.self) {
                                color in
                                ZStack {
                                    Circle()
                                        .foregroundColor(color.value)
                                        .onTapGesture {
                                            self.color = color
                                        }
                                    if color == self.color {
                                        Circle()
                                            .stroke(lineWidth: 4)
                                            .foregroundColor(.themeForeground)
                                    }
                                }
                                .frame(width: 30)
                            }
                        }
                    }
                }
                
                Section {
                    DatePicker("Starts", selection: $starts)
                    DatePicker("Ends", selection: $ends)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddEventForm = false
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try await DataService.shared.createNewEvent(event: Event(title: title, starts: starts, ends: ends, color: color))
                        }
                        showAddEventForm = false
                    } label: {
                        if title.isEmpty {
                            Text("Add")
                                .foregroundStyle(.gray)
                        } else {
                            Text("Add")
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddNewEvent(showAddEventForm: .constant(true))
}

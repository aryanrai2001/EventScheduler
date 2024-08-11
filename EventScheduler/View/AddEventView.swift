//
//  AddNewEvent.swift
//  EventScheduler
//
//  Created by Aryan Rai on 09/08/24.
//

import SwiftUI

struct AddEventView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var id: UUID?
    @State var title: String = ""
    @State var starts: Date = Date.now
    @State var ends: Date = Date.now
    @State var color: EventColor = .red
    
    var onUpdate: (Event) -> Void = { _ in }
    
    private var minEndDate: Date {
        Calendar.current.date(byAdding: .minute, value: 5, to: starts)!
    }
    
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
                    
                    DatePicker("Ends", selection: $ends, in: minEndDate...)
                        .onAppear {
                            ends = max(minEndDate, ends)
                        }
                }
            }
            .navigationTitle("\(id == nil ? "New" : "Edit") Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            var event = Event(title: title, starts: starts, ends: ends, color: color)
                            if let id {
                                event.id = id
                            }
                            try await DataService.shared.createNewEvent(event: event)
                            onUpdate(event)
                        }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        if title.isEmpty {
                            Text(id == nil ? "Add" : "Done")
                                .foregroundStyle(.gray)
                        } else {
                            Text(id == nil ? "Add" : "Done")
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddEventView()
}

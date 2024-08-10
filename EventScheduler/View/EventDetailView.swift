//
//  EventDetailView.swift
//  EventScheduler
//
//  Created by Aryan Rai on 10/08/24.
//

import SwiftUI

struct EventDetailView: View {
    
    @Binding var event: Event?
    
    @State private var showEditForm: Bool = false
    
    var body: some View {
        if let event {
            ZStack {
                Color.themeBackground.opacity(0.1)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .backgroundStyle(.ultraThinMaterial)
                    .onTapGesture {
                        self.event = nil
                    }
                
                ZStack {
                    event.color.value
                    Color.black.opacity(0.2)
                    
                    Button(action: {
                        self.event = nil
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.themeLight)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding()
                    
                    VStack(spacing: 25) {
                        Text("\(event.title)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.themeLight)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.6)
                            .lineLimit(4)
                            .font(.title)
                            .bold()
                        
                        VStack(spacing: 1) {
                            Text("From: ")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.black)
                            
                            Text("\(event.starts.formatted(date: .complete, time: .omitted))")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.regular)
                            
                            Text("At \(event.starts.formatted(date: .omitted, time: .shortened))")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.regular)
                        }
                        
                        VStack(spacing: 1) {
                            Text("To: ")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.black)
                            
                            Text("\(event.ends.formatted(date: .complete, time: .omitted))")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.regular)
                            
                            Text("At \(event.ends.formatted(date: .omitted, time: .shortened))")
                                .foregroundStyle(.themeLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.regular)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 80)
                    .padding(.horizontal, 25)
                    
                    VStack {
                        Spacer()
                        
                        Divider()
                            .background(.themeLight)
                        
                        Button(action: {
                            showEditForm = true
                        }, label: {
                            Label("Edit Event", systemImage: "square.and.pencil")
                        })
                        
                        Divider()
                            .background(.themeLight)
                        
                        Button(action: {
                            Task {
                                try await
                                DataService.shared.deleteEvent(eventId: event.id);
                            }
                        }, label: {
                            Label("Delete Event", systemImage: "trash")
                        })
                    }
                    .foregroundStyle(.themeLight)
                    .padding(.vertical)
                }
                .frame(width: 300, height: 475)
                .cornerRadius(10)
                .shadow(color: .themeForeground.opacity(0.5), radius: 25)
            }
            .sheet(isPresented: $showEditForm, onDismiss: {
                withAnimation(.timingCurve(.easeInOut, duration: 0.05)) {
                    self.event = nil
                }
            }, content: {
                AddEventView(id: event.id, title: event.title, starts: event.starts, ends: event.ends, color: event.color)
            })
        }
    }
}

#Preview {
    ZStack {
        HomeView()
            .background(.themeBackground)
    }
}

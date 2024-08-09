//
//  ContentView.swift
//  EventScheduler
//
//  Created by Aryan Rai on 08/08/24.
//

import SwiftUI

@MainActor
final class EventViewModel: ObservableObject {
    
    @Published var events: [Event] = []
    @Published var allDayEvents: [Event] = []
    
    func startListening( date: Date?) {
        guard let date else {
            return
        }
        events = []
        allDayEvents = []
        DataService.shared.addListenerForEvent(date: date) { events in
            DispatchQueue.main.async {
                self.events = events
            }
        }
        DataService.shared.addListenerForAllDayEvent(date: date) { events in
            DispatchQueue.main.async {
                self.allDayEvents = events
            }
        }
    }
}

struct HomeView: View {
    
    @StateObject private var viewModel = EventViewModel()
    
    @State private var showAddEventForm: Bool = false
    @State private var compactView: Bool = false
    
    @State private var selectedYear: Int? = nil
    @State private var selectedMonth: Int? = nil
    @State private var selectedDay: Int = 0
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                
                CalendarView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay, compact: $compactView) {
                    showAddEventForm = true
                }
                .padding([.horizontal, .top])
                .background {
                    VStack(spacing: 0){
                        Color.themeBackground
                            .frame(height: compactView ? 197 : 472)
                        Rectangle().fill(.linearGradient(colors: [Color.themeBackground, Color.clear, Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 50)
                    }
                    .ignoresSafeArea()
                }
                .zIndex(100)
                
                if selectedYear != nil && selectedMonth != nil {
                    Group {
                        if compactView {
                            TimelineView(date: getDate()!)
                        } else {
                            EventListView(date: getDate()!)
                        }
                    }
                    .onChange(of: selectedYear) {
                        viewModel.startListening(date: getDate())
                    }
                    .onChange(of: selectedMonth) {
                        viewModel.startListening(date: getDate())
                    }
                    .onChange(of: selectedDay) {
                        viewModel.startListening(date: getDate())
                    }
                    
                } else {
                    GeometryReader {
                        proxy in
                        Text("No date selected!")
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundStyle(.themeForeground)
                            .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddEventForm) {
            AddNewEvent(showAddEventForm: $showAddEventForm)
        }
        .onAppear {
            selectedYear = Calendar.current.component(.year, from: Date.now)
            selectedMonth = Calendar.current.component(.month, from: Date.now)
            selectedDay = Calendar.current.component(.day, from: Date.now)
            viewModel.startListening(date: getDate())
        }
    }
    
    @ViewBuilder
    func EventListView(date: Date) -> some View {
        if viewModel.events.isEmpty {
            GeometryReader {
                proxy in
                Text("No events found!")
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundStyle(.themeForeground)
                    .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.events) { event in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(event.color.value.opacity(0.6))
                            .frame(height: 60)
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(event.color.value)
                            .frame(height: 60)
                            .mask {
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: 7)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 5) {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.themeForeground)
                                        .font(.caption)
                                        .bold()
                                    Text("\(event.starts.formatted(date: .omitted, time: .shortened))")
                                        .foregroundStyle(.themeForeground)
                                        .font(.caption)
                                        .bold()
                                }
                                HStack(spacing: 5)  {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.themeForeground)
                                        .font(.caption)
                                        .bold()
                                    Text("\(event.ends.formatted(date: .omitted, time: .shortened))")
                                        .foregroundStyle(.themeForeground)
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .padding(.leading, 15)
                            Spacer()
                            Text("\(event.title)")
                                .foregroundStyle(.themeForeground)
                                .padding(.trailing, 15)
                        }
                    }
                    .padding(.horizontal)
                    .shadow(color: event.color.value.opacity(0.2), radius: 5)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    @ViewBuilder
    func TimelineView(date: Date) -> some View {
        let hours = Array(0..<24).compactMap { offset in
            Calendar.current.date(byAdding: .hour, value: offset, to: Calendar.current.startOfDay(for: date))!
        }
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack {
                        VStack {
                            ForEach(hours, id:\.self) {
                                hour in
                                ZStack(alignment: .leading) {
                                    Text(hour.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 13))
                                        .bold()
                                        .frame(width: 60, alignment: .leading)
                                        .position(x:35)
                                    HStack {
                                        Spacer()
                                            .frame(width: 70)
                                        Rectangle().stroke(style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .round, dash: [5], dashPhase: 1))
                                            .frame(height: 0.5)
                                    }
                                    .padding(.bottom, 51.5)
                                    .id(hour)
                                }
                            }
                        }
                        HStack {
                            Spacer()
                                .frame(width: 70)
                            ZStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    GeometryReader {
                                        geometry in
                                        let scrollPos = geometry.frame(in: .named("scroll")).origin
                                        let yStart = -20-Int(scrollPos.y)
                                        let yEnd = yStart + 645
                                        let startTime = getPositionTime(position: yStart)
                                        let endTime = getPositionTime(position: yEnd)
                                        let filteredEvents = viewModel.events.filter {
                                            event in
                                            return event.starts < endTime && event.ends > startTime
                                        }
                                        
                                        let allEvents = viewModel.allDayEvents + filteredEvents
                                        
                                        ForEach(allEvents.indices, id:\.self) {
                                            index in
                                            EventIndicatorView(event: allEvents[index], xOffset: index, yStart: yStart, yEnd: yEnd)
                                        }
                                    }
                                    .frame(width: CGFloat(viewModel.events.count) * 100)
                                }
                                if date == Calendar.current.startOfDay(for: Date.now) {
                                    GeometryReader { geometry in
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .position(x: 0, y: CGFloat(getTimePosition(time: Date.now)))
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 1)
                                            .position(x: geometry.frame(in: .local).midX, y: CGFloat(getTimePosition(time: Date.now)))
                                    }
                                    .foregroundStyle(.themeCyan)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(hours[12], anchor: .top)
                    }
                }
                .onChange(of: date) {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(hours[12], anchor: .top)
                    }
                }
            }
            .scrollClipDisabled()
            .padding(.horizontal)
            .coordinateSpace(name: "scroll")
        }
    }
    
    @ViewBuilder
    func EventIndicatorView(event: Event, xOffset: Int, yStart: Int, yEnd: Int) -> some View{
        let eventStartPos = max(getTimePosition(time: event.starts), yStart)
        let eventEndPos = min(getTimePosition(time: event.ends), yEnd)
        let width = 100
        let height = eventEndPos - eventStartPos
        ZStack {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(event.color.value.opacity(0.5))
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 3)
                    .foregroundStyle(event.color.value)
                
                if height > 20 {
                    Text("\(event.title)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.themeForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                    
                }
            }
            .frame(width: CGFloat(width - 3), height: CGFloat(height))
            .position(x: CGFloat(width * xOffset + width / 2), y: CGFloat(eventStartPos + height / 2))
        }
    }
    
    func getTimePosition(time: Date) -> Int {
        var hours = Calendar.current.component(.hour, from: time)
        var minutes = Calendar.current.component(.minute, from: time)
        if time < getDate()! {
            hours = 0
            minutes = 0
        } else if time >= Calendar.current.date(byAdding: .day, value: 1, to: getDate()!)! {
            hours = 23
            minutes = 59
        }
        return hours * 60 + minutes
    }
    
    func getPositionTime(position: Int) -> Date {
        let hours = position / 60
        let minutes = position % 60
        return Calendar.current.date(byAdding: .hour, value: hours, to: Calendar.current.date(byAdding: .minute, value: minutes, to: Calendar.current.startOfDay(for: getDate()!))!)!
    }
    
    func getDate() -> Date? {
        return Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay))
    }
}

#Preview {
    HomeView()
        .background(.themeBackground)
}

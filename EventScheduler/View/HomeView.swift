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
    @Published var offsets: [Int] = []
    
    func startListening(date: Date?) {
        guard let date else {
            return
        }
        withAnimation(.timingCurve(.linear, duration: 0.05)) {
            events = []
            offsets = []
        }
        DataService.shared.addListenerForEvent(date: date) { events in
            DispatchQueue.main.async {
                withAnimation(.timingCurve(.linear, duration: 0.05)) {
                    self.events = events
                    self.offsets = self.calculateEventOffsets(sortedEvents: events)
                }
            }
        }
    }
    
    private func calculateEventOffsets(sortedEvents: [Event]) -> [Int] {
        var columns: [[Date]] = []
        var eventColumns: [Int] = []
        
        for event in sortedEvents {
            var placed = false
            
            for (index, column) in columns.enumerated() {
                if column.last! <= event.starts {
                    columns[index].append(event.ends)
                    eventColumns.append(index)
                    placed = true
                    break
                }
            }
            
            if !placed {
                columns.append([event.ends])
                eventColumns.append(columns.count - 1)
            }
        }
        
        return eventColumns
    }
}

struct HomeView: View {
    
    @StateObject private var viewModel = EventViewModel()
    
    @State private var showAddEventForm: Bool = false
    @State private var chartMode: Bool = false
    
    @State private var selectedYear: Int? = nil
    @State private var selectedMonth: Int? = nil
    @State private var selectedDay: Int = 1
    
    @State private var chartWidth: CGFloat = 100
    
    @State private var eventToEdit: Event?
    @State private var eventToView: Event?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    CalendarView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay, compact: $chartMode, onPressAdd: {
                        showAddEventForm = true
                    }, onChange: {
                        viewModel.startListening(date: getDate())
                    })
                    .padding([.horizontal, .top])
                    .background {
                        if chartMode {
                            VStack(spacing: 0){
                                Color.themeBackground
                                    .frame(height: 175)
                                
                                Rectangle().fill(.linearGradient(colors: [Color.themeBackground.opacity(0.5), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 50)
                            }
                        }
                    }
                    .zIndex(100)
                    
                    if selectedYear != nil && selectedMonth != nil {
                        Group {
                            if chartMode {
                                TimelineView(date: getDate()!)
                            } else {
                                EventListView(date: getDate()!)
                            }
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
                    
                    VStack(spacing: 0) {
                        if chartMode {
                            Rectangle().fill(.linearGradient(colors: [Color.themeBackground.opacity(0.5), Color.clear], startPoint: .bottom, endPoint: .top))
                                .frame(height: 50)
                        }
                        
                        Divider()
                            .background(.themeForeground)
                        
                        ZStack {
                            Color.themeBackground
                            
                            Button(action: {
                                withAnimation(.timingCurve(.linear, duration: 0.1)) {
                                    setDateToToday()
                                }
                            }, label: {
                                Text("Today")
                            })
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.themeOrange)
                    }
                }
            }
            .onAppear {
                setDateToToday()
            }
            .sheet(isPresented: $showAddEventForm) {
                AddEventView()
            }
            .sheet(item: $eventToEdit) {
                eventToEdit = nil
            } content: { event in
                AddEventView(id: event.id, title: event.title, starts: event.starts, ends: event.ends, color: event.color)
            }
            .blur(radius: (eventToView != nil) ? 3.0 : 0)
            
            if eventToView != nil {
                EventDetailView(event: $eventToView)
                    .transition(.scale)
            }
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
            ScrollView {
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
                            HStack(spacing: 25) {
                                Text("\(event.title)")
                                    .fixedSize(horizontal: false, vertical: false)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.themeLight)
                                    .padding(.leading, 15)
                                    .lineLimit(2)
                                    .font(.body)
                                
                                VStack(alignment: .leading) {
                                    if event.isAllDay {
                                        HStack(spacing: 5) {
                                            Image(systemName: "clock")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                            
                                            Text("All Day")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                        }
                                    }
                                    else {
                                        HStack(spacing: 5) {
                                            Image(systemName: "clock")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                            
                                            Text("Starts")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                            
                                            Text("\(event.starts.formatted(date: .omitted, time: .shortened))")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .fontWeight(.black)
                                        }
                                        HStack(spacing: 5)  {
                                            Image(systemName: "clock")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                            
                                            Text("Ends")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .bold()
                                            
                                            Text("\(event.ends.formatted(date: .omitted, time: .shortened))")
                                                .foregroundStyle(.themeLight)
                                                .font(.caption)
                                                .fontWeight(.black)
                                        }
                                    }
                                }
                                .padding(.trailing, 15)
                            }
                        }
                        .onTapGesture {
                            Task {
                                let fetchedEvent = try await DataService.shared.getEvent(eventId: event.id)
                                DispatchQueue.main.async {
                                    withAnimation(.timingCurve(.easeInOut, duration: 0.15)) {
                                        eventToView = fetchedEvent
                                    }
                                }
                            }
                        }
                        .contextMenu {
                            Button {
                                Task {
                                    let fetchedEvent = try await DataService.shared.getEvent(eventId: event.id)
                                    DispatchQueue.main.async {
                                        eventToEdit = fetchedEvent
                                    }
                                }
                            } label: {
                                Label("Edit Event", systemImage: "square.and.pencil")
                            }
                            
                            Button(role: .destructive) {
                                Task {
                                    try await DataService.shared.deleteEvent(eventId: event.id);
                                }
                            } label: {
                                Label("Delete Event", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal)
                        .shadow(color: event.color.value.opacity(0.2), radius: 5)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .scrollClipDisabled()
            .mask {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 310)
            }
        }
    }
    
    @ViewBuilder
    func TimelineView(date: Date) -> some View {
        let hours = Array(0..<24).compactMap { offset in
            Calendar.current.date(byAdding: .hour, value: offset, to: Calendar.current.startOfDay(for: date))!
        }
        ZStack(alignment: .bottom) {
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
                                HStack {
                                    Rectangle().stroke(style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .round, dash: [5], dashPhase: 1))
                                        .frame(height: 0.5)
                                }
                                .padding(.bottom, 51.5)
                            }
                            
                            HStack {
                                Spacer()
                                    .frame(width: 70)
                                
                                ZStack {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        GeometryReader {
                                            geometry in
                                            
                                            let scrollX = geometry.frame(in: .named("scrollX"))
                                            
                                            let xStart = 1-Int(scrollX.origin.x)
                                            let xEnd = xStart + 289
                                            
                                            let scrollY = geometry.frame(in: .named("scrollY"))
                                            
                                            let yStart = -22-Int(scrollY.origin.y)
                                            let yEnd = yStart + 567
                                            
                                            ForEach(viewModel.events.indices, id:\.self) {
                                                index in
                                                
                                                EventIndicatorView(event: viewModel.events[index], xOffset: viewModel.offsets[index], xStart: xStart, xEnd: xEnd, yStart: yStart, yEnd: yEnd)
                                            }
                                        }
                                        .frame(width: CGFloat(((viewModel.offsets.max() ?? 0) + 1) * 100))
                                    }
                                    .coordinateSpace(name: "scrollX")
                                    
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
                        withAnimation(.timingCurve(.linear, duration: 0.1)) {
                            proxy.scrollTo(hours[12], anchor: .top)
                        }
                    }
                    .onChange(of: date) {
                        withAnimation(.timingCurve(.linear, duration: 0.1)) {
                            proxy.scrollTo(hours[12], anchor: .top)
                        }
                    }
                }
                .scrollClipDisabled()
                .mask(
                    Rectangle()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .frame(height: 600)
                )
                .padding(.horizontal)
                .coordinateSpace(name: "scrollY")
            }
        }
    }
    
    @ViewBuilder
    func EventIndicatorView(event: Event, xOffset: Int, xStart: Int, xEnd: Int, yStart: Int, yEnd: Int) -> some View{
        let cardWidth = 100
        
        let yStartPos = max(getTimePosition(time: event.starts), yStart)
        let yEndPos = min(getTimePosition(time: event.ends), yEnd)
        let height = yEndPos - yStartPos

        let xStartPos = max(cardWidth * xOffset, xStart)
        let xEndPos = min(cardWidth * xOffset + cardWidth, xEnd)
        let width = xEndPos - xStartPos
        
        if height > 4  && width > 4{
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(event.color.value.opacity(0.8))
                    .frame(width: CGFloat(width), height: CGFloat(height))
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 3)
                    .foregroundStyle(event.color.value)
                    .frame(width: CGFloat(width-3), height: CGFloat(height-3))
                
                if height > 20 && width > 50{
                    Text("\(event.title)")
                        .fixedSize(horizontal: false, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.themeLight)
                        .padding(.horizontal, 5)
                        .lineLimit(nil)
                        .font(.caption)
                        .bold()
                    
                }
            }
            .frame(width: CGFloat(width), height: CGFloat(height))
            .position(x: CGFloat(xStartPos) + CGFloat(width) / 2, y: CGFloat(yStartPos) + CGFloat(height) / 2)
            .onTapGesture {
                Task {
                    let fetchedEvent = try await DataService.shared.getEvent(eventId: event.id)
                    DispatchQueue.main.async {
                        withAnimation(.timingCurve(.easeInOut, duration: 0.15)) {
                            eventToView = fetchedEvent
                        }
                    }
                }
            }
        }
    }
    
    func getTimePosition(time: Date) -> Int {
        let hours = Calendar.current.component(.hour, from: time)
        let minutes = Calendar.current.component(.minute, from: time)
        return  max(min((hours * 60 + minutes), 1440), 1)
    }
    
    func getDate() -> Date? {
        return Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay))
    }
    
    func setDateToToday() {
        let currentYear = Calendar.current.component(.year, from: Date.now)
        let currentMonth = Calendar.current.component(.month, from: Date.now)
        let currentDay = Calendar.current.component(.day, from: Date.now)
        
        if selectedYear != currentYear || selectedMonth != currentMonth || selectedDay != currentDay {
            selectedYear = currentYear
            selectedMonth = currentMonth
            selectedDay = currentDay
            viewModel.startListening(date: getDate())
        }
    }
}

#Preview {
    HomeView()
        .background(.themeBackground)
}

//
//  CalendarView.swift
//  EventScheduler
//
//  Created by Aryan Rai on 08/08/24.
//

import SwiftUI

struct CalendarView: View {
    
    @Binding var selectedYear: Int?
    @Binding var selectedMonth: Int?
    @Binding var selectedDay: Int
    @Binding var compact: Bool
    
    var onPressAdd: () -> Void = {}
    var onChange: () -> Void = {}
    
    @State private var yearRangeStart: Int = (Int(Date.now.formatted(.dateTime.year()))! / 20) * 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Year
            if let selectedYear {
                
                if !compact {
                    HStack(alignment: .bottom, spacing: 0) {
                        YearHeading(selectedYear: selectedYear)
                        Spacer()
                        HStack {
                            CompactButton()
                            Button {
                                onPressAdd()
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.themeOrange)
                                    .font(.title2)
                            }
                        }
                    }
                }
                // Month
                if let selectedMonth {
                    HStack(alignment: .bottom, spacing: 0) {
                        MonthHeading(selectedMonth: selectedMonth)
                        if compact {
                            Text(", ")
                                .font(.title2)
                            YearHeading(selectedYear: selectedYear)
                        }
                            
                        Spacer()
                        
                        if compact {
                            HStack {
                                CompactButton()
                                Button {
                                    onPressAdd()
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.themeOrange)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    //Day
                    DaySelectView()
                        .padding(.top, 10)
                } else {
                    MonthSelectView()
                        .padding(.top, 10)
                }
            } else {
                YearSelectView()
            }
            
            Divider()
                .background(.themeForeground)
                .padding(.vertical)
        }
        .onAppear {
            if compact {
                compact = self.selectedYear != nil && self.selectedMonth != nil
            }
        }
    }
    
    @ViewBuilder
    func CompactButton() -> some View {
        Button {
            withAnimation {
                if compact {
                    compact = false
                } else {
                    if self.selectedYear != nil && self.selectedMonth != nil {
                        compact = true
                    }
                }
            }
        } label: {
            if compact {
                Image(systemName: "list.bullet.below.rectangle")
                    .padding(5)
                    .foregroundColor(.themeLight)
                    .background(.themeOrange)
                    .cornerRadius(5)
                    .font(.title2)
            } else {
                if self.selectedYear == nil ||
                    self.selectedMonth == nil {
                    Image(systemName: "list.bullet")
                        .padding(5)
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.title2)
                } else {
                    Image(systemName: "list.bullet")
                        .padding(5)
                        .foregroundColor(.themeOrange)
                        .font(.title2)
                }
            }
        }
        .disabled(self.selectedYear == nil || self.selectedMonth == nil)
    }
    
    @ViewBuilder
    func YearHeading(selectedYear: Int) -> some View {
        HStack {
            if selectedMonth == nil {
                Button {
                    withAnimation {
                        self.selectedYear! -= 1
                        onChange()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.themeOrange)
                        .font(.title2)
                }
            }
            
            Button {
                withAnimation {
                    self.yearRangeStart = (selectedYear / 20) * 20
                    self.selectedYear = nil
                }
            } label: {
                Text(String(selectedYear))
                    .foregroundStyle(.themeForeground)
                    .font(.title2)
            }
            .disabled(compact)
            
            if selectedMonth == nil {
                Button {
                    withAnimation {
                        self.selectedYear! += 1
                        onChange()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.themeOrange)
                        .font(.title2)
                }
            }
        }
    }
    
    @ViewBuilder
    func MonthHeading(selectedMonth: Int) -> some View {
        HStack {
            if !compact {
                Button {
                    withAnimation {
                        self.selectedMonth = (selectedMonth + 10) % 12 + 1
                        onChange()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.themeOrange)
                        .font(.title2)
                }
            }
            
            Button {
                withAnimation {
                    self.selectedMonth = nil
                }
            } label: {
                Text(Calendar.current.monthSymbols[selectedMonth-1])
                    .foregroundStyle(.themeForeground)
                    .font(compact ? .system(size: 30) : .title)
            }
            .disabled(compact)
            
            if !compact {
                Button {
                    withAnimation {
                        self.selectedMonth = (selectedMonth + 12)  % 12 + 1
                        onChange()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.themeOrange)
                        .font(.title2)
                }
            }
        }
    }
    
    @ViewBuilder
    func YearSelectView() -> some View {
        HStack {
            Button {
                withAnimation {
                    yearRangeStart -= 20
                    onChange()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.themeOrange)
                    .font(.title2)
            }
            Text("\(String(yearRangeStart + 1)) - \(String(yearRangeStart + 20))")
                .foregroundStyle(.themeForeground)
                .font(.title2)
            Button {
                withAnimation {
                    yearRangeStart += 20
                    onChange()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeOrange)
                    .font(.title2)
            }
        }
        Divider()
            .background(.themeForeground)
            .padding(.vertical, 10)
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(65)), count: 5), spacing: 5, content: {
                ForEach(1...20, id:\.self) {
                    offset in
                    Button(action: {
                        withAnimation {
                            self.selectedYear = yearRangeStart + offset
                            self.selectedMonth = nil
                            self.selectedDay = 1
                        }
                    }, label: {
                        Text(String(yearRangeStart + offset))
                            .foregroundStyle(.themeForeground)
                            .font(.body)
                            .bold()
                    })
                }
            })
        }
    }
    
    @ViewBuilder
    func MonthSelectView() -> some View {
        Divider()
            .background(.themeForeground)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 50, maximum: 200)), count: 3), alignment: .leading, spacing: 5, content: {
            ForEach(1...12, id:\.self) {
                month in
                Button(action: {
                    withAnimation {
                        self.selectedMonth = month
                        self.selectedDay = 1
                        onChange()
                    }
                }, label: {
                    Text(Calendar.current.monthSymbols[month-1])
                        .foregroundStyle(.themeForeground)
                        .font(.body)
                        .bold()
                })
                .padding(.horizontal, 13)
            }
        })
    }
    
    @ViewBuilder
    func DaySelectView() -> some View {
        
        let month = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
        
        let days: [Date] = Calendar.current.range(of: .day, in: .month, for: month)?.compactMap({ day in
            Calendar.current.date(byAdding: .day, value: day-1, to: month)
        }) ?? []
        
        let firstWeekday = Calendar.current.component(.weekday, from: days.first!)
        let lastWeekday = Calendar.current.component(.weekday, from: days.last!)
        
        let prevMonthDays = Array(0..<firstWeekday-1).reversed().compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset-1, to: days.first!)
        }
        let nextMonthDays = Array(0..<(7-lastWeekday)).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset+1, to: days.last!)
        }
        
        VStack {
            if !compact {
                Divider()
                    .background(.themeForeground)
                HStack {
                    ForEach(Calendar.current.weekdaySymbols, id:\.self) {
                        week in
                        Text(week.prefix(3))
                            .foregroundStyle(.themeForeground)
                            .frame(width: 45)
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
                Divider()
                .background(.themeForeground)
            }
            
            if !compact {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(45)), count: 7), spacing: 5, content: {
                    ForEach(prevMonthDays, id:\.self) { day in
                        Text(day.formatted(.dateTime.day(.twoDigits)))
                            .frame(width: 45)
                            .foregroundStyle(.themeForeground)
                            .font(.body)
                            .fontWeight(.ultraLight)
                    }
                    ForEach(days, id:\.self) {
                        day in
                        Button(action: {
                            withAnimation {
                                self.selectedDay = Int(day.formatted(.dateTime.day())) ?? 1
                                onChange()
                            }
                        }, label: {
                            let date = day.formatted(.dateTime.day(.twoDigits))
                            let isSelected = Int(date) == selectedDay
                            Text(date)
                                .padding(10)
                                .frame(width: 45)
                                .foregroundStyle(isSelected ? .themeLight :  .themeForeground)
                                .background(isSelected ? .themeOrange :  .clear)
                                .cornerRadius(5)
                                .font(.body)
                                .bold()
                        })
                    }
                    ForEach(nextMonthDays, id:\.self) { day in
                        Text(day.formatted(.dateTime.day(.twoDigits)))
                            .frame(width: 45)
                            .foregroundStyle(.themeForeground)
                            .font(.body)
                            .fontWeight(.ultraLight)
                    }
                })
            }  else {
                Divider()
                    .background(.themeForeground)
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(days, id:\.self) {
                                day in
                                
                                let date = day.formatted(.dateTime.day(.twoDigits))
                                let isSelected = Int(date) == selectedDay
                                let weekDay = Calendar.current.component(.weekday, from: day)
                                
                                Button(action: {
                                    withAnimation {
                                        self.selectedDay = Int(day.formatted(.dateTime.day())) ?? 1
                                        onChange()
                                    }
                                }, label: {
                                    VStack {
                                        Text(Calendar.current.weekdaySymbols[weekDay-1].prefix(3))
                                            .font(.caption)
                                        Text(date)
                                            .font(.body)
                                            .bold()
                                    }
                                    .padding(5)
                                    .frame(width: 37)
                                    .foregroundStyle(isSelected ? .themeLight :  .themeForeground)
                                    .background(isSelected ? .themeOrange :  .clear)
                                    .cornerRadius(5)
                                })
                                .id(Int(date))
                            }
                        }
                        .onChange(of: selectedDay) {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(selectedDay, anchor: .center)
                                }
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                proxy.scrollTo(selectedDay, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
//    CalendarView(selectedYear: .constant(2001), selectedMonth: .constant(12), selectedDay: .constant(31)) {
//        print("Preview Test: Add Button Pressed")
//    }
//    .padding()
    HomeView()
        .background(.themeBackground)
}

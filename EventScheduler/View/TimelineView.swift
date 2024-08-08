//
//  ContentView.swift
//  EventScheduler
//
//  Created by Aryan Rai on 08/08/24.
//

import SwiftUI

struct TimelineView: View {
    
    @State private var showAddEventView: Bool = false
    @State private var compactView: Bool = true
    
    @State private var selectedYear: Int? = 2021
    @State private var selectedMonth: Int? = 3
    @State private var selectedDay: Int?
    
    var body: some View {
        GeometryReader { geometry in
//            let safeArea = geometry.safeAreaInsets
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    CalendarView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay, compact: $compactView) {
                        showAddEventView = true
                    }
                        .padding()
                    VStack(spacing: 15) {
                        ForEach(1...15, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 75)
                                .foregroundColor(.themeCyan)
                                .padding(.horizontal, 15)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
//            .ignoresSafeArea(.container, edges: .top)
        }
        .sheet(isPresented: $showAddEventView) {
            ProgressView()
        }
    }
    
    @ViewBuilder 
    func CalenderView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
        }
    }
}

#Preview {
    TimelineView()
        .background(.themeBackground)
}

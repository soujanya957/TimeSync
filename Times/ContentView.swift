//
//  ContentView.swift
//  Times
//
//  Created by Soujanya C. Aryal on 09/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTimes: [String: Date] = [
        "Asia/Kathmandu": Date(),
        "Europe/Moscow": Date(),
        "Asia/Beirut": Date(),
        "Asia/Hong_Kong": Date(),
        "Asia/Tokyo": Date(),
        "Asia/Manila": Date()
    ]
    
    @State private var use24HourFormat = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("World Clocks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Toggle(isOn: $use24HourFormat) {
                    Text("24-Hour Format")
                        .font(.headline)
                        .padding(.horizontal)
                }
                .padding()
                
                List {
                    TimeView(city: "Kathmandu", timeZoneIdentifier: "Asia/Kathmandu", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                    TimeView(city: "Moscow", timeZoneIdentifier: "Europe/Moscow", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                    TimeView(city: "Beirut", timeZoneIdentifier: "Asia/Beirut", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                    TimeView(city: "Hong Kong", timeZoneIdentifier: "Asia/Hong_Kong", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                    TimeView(city: "Japan", timeZoneIdentifier: "Asia/Tokyo", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                    TimeView(city: "Philippines", timeZoneIdentifier: "Asia/Manila", selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("World Clocks", displayMode: .inline)
        }
    }
}

struct TimeView: View {
    let city: String
    let timeZoneIdentifier: String
    @Binding var selectedTimes: [String: Date]
    @Binding var use24HourFormat: Bool
    
    @State private var showingDatePicker = false
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(city)
                    .font(.headline)
                    .padding(.vertical, 5)
                Spacer()
                Text(formattedTime(for: timeZoneIdentifier))
                    .font(.body)
                    .padding(.vertical, 5)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        showingDatePicker = true
                    }
                    .sheet(isPresented: $showingDatePicker) {
                        VStack {
                            DatePicker(
                                "Select Time",
                                selection: Binding(
                                    get: {
                                        selectedTimes[timeZoneIdentifier] ?? Date()
                                    },
                                    set: { newValue in
                                        updateSelectedTimes(for: timeZoneIdentifier, with: newValue)
                                    }
                                ),
                                displayedComponents: [.hourAndMinute, .date]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .padding()
                            
                            Button("Done") {
                                showingDatePicker = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
            }
            Divider()
        }
        .padding(.horizontal)
    }
    
    func formattedTime(for timeZoneIdentifier: String) -> String {
        timeFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        timeFormatter.dateFormat = use24HourFormat ? "HH:mm, MMM d, yyyy" : "h:mm a, MMM d, yyyy"
        let selectedTime = selectedTimes[timeZoneIdentifier] ?? Date()
        return timeFormatter.string(from: selectedTime)
    }
    
    func updateSelectedTimes(for timeZoneIdentifier: String, with newValue: Date) {
        let selectedTime = newValue
        let sourceTimeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
        selectedTimes = selectedTimes.mapValues { currentTime in
            let targetTimeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
            return convertTime(selectedTime, from: sourceTimeZone, to: targetTimeZone)
        }
    }
    
    func convertTime(_ date: Date, from sourceTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let sourceOffset = TimeInterval(sourceTimeZone.secondsFromGMT(for: date))
        let targetOffset = TimeInterval(targetTimeZone.secondsFromGMT(for: date))
        return date.addingTimeInterval(targetOffset - sourceOffset)
    }
}


#Preview {
    ContentView()
}

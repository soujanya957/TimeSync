//
//  ClockView.swift
//  Times
//
//  Created by Soujanya C. Aryal on 09/06/2024.
//
import SwiftUI

struct ClockView: View {
    @State private var selectedTimes: [String: Date] = [:]
    @State private var availableCities: [(String, String)] = [
        ("Providence", "America/New_York"),
        ("Moscow", "Europe/Moscow"),
        ("Manila", "Asia/Manila"),
        ("Tokyo", "Asia/Tokyo"),
        ("Hong Kong", "Asia/Hong_Kong"),
        ("Beirut", "Asia/Beirut"),
        ("Kathmandu", "Asia/Kathmandu"),
        ("New York", "America/New_York"),
        ("London", "Europe/London"),
        ("Paris", "Europe/Paris"),
        ("Berlin", "Europe/Berlin"),
        ("Sydney", "Australia/Sydney"),
        ("Los Angeles", "America/Los_Angeles"),
        ("San Francisco", "America/Los_Angeles"),
        ("Chicago", "America/Chicago"),
        ("Boston", "America/New_York"),
        ("Bangkok", "Asia/Bangkok"),
        ("Mumbai", "Asia/Kolkata"),
        ("Shanghai", "Asia/Shanghai"),
        ("Singapore", "Asia/Singapore")
    ]
    @State private var use24HourFormat = false
    @State private var showingCityPicker = false

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
                    ForEach(selectedTimes.keys.sorted(), id: \.self) { timeZoneIdentifier in
                        if let city = availableCities.first(where: { $0.1 == timeZoneIdentifier })?.0 {
                            TimeDisplayView(city: city, timeZoneIdentifier: timeZoneIdentifier, selectedTimes: $selectedTimes, use24HourFormat: $use24HourFormat)
                        }
                    }
                    .onDelete(perform: removeCities)
                }
                .listStyle(InsetGroupedListStyle())

                Button(action: {
                    showingCityPicker = true
                }) {
                    Text("Add City")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitle("World Clocks", displayMode: .inline)
            .sheet(isPresented: $showingCityPicker) {
                CityPickerView(availableCities: $availableCities, selectedTimes: $selectedTimes, isPresented: $showingCityPicker)
            }
        }
    }

    func removeCities(at offsets: IndexSet) {
        let keysToRemove = offsets.map { selectedTimes.keys.sorted()[$0] }
        for key in keysToRemove {
            selectedTimes.removeValue(forKey: key)
        }
    }
}

struct TimeDisplayView: View {
    let city: String
    let timeZoneIdentifier: String
    @Binding var selectedTimes: [String: Date]
    @Binding var use24HourFormat: Bool

    @State private var showingDatePicker = false

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
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        formatter.dateFormat = use24HourFormat ? "HH:mm, MMM d, yyyy" : "h:mm a, MMM d, yyyy"
        let selectedTime = selectedTimes[timeZoneIdentifier] ?? Date()
        return formatter.string(from: selectedTime)
    }

    func updateSelectedTimes(for timeZoneIdentifier: String, with newValue: Date) {
        selectedTimes[timeZoneIdentifier] = newValue
    }
}


struct CityPickerView: View {
    @Binding var availableCities: [(String, String)]
    @Binding var selectedTimes: [String: Date]
    @Binding var isPresented: Bool
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                List {
                    ForEach(filteredCities(), id: \.1) { city in
                        HStack {
                            Text(city.0)
                            Spacer()
                            if selectedTimes.keys.contains(city.1) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTimes.keys.contains(city.1) {
                                selectedTimes.removeValue(forKey: city.1)
                            } else {
                                selectedTimes[city.1] = Date()
                            }
                        }
                    }
                }
                .navigationBarTitle("Select Cities", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    isPresented = false
                })
            }
        }
    }

    func filteredCities() -> [(String, String)] {
        if searchText.isEmpty {
            return availableCities
        } else {
            return availableCities.filter { $0.0.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search Cities"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

#Preview {
    ClockView()
}

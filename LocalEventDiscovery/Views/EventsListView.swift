//
//  EventsListView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//

import SwiftUI
import CoreLocation

struct EventsListView: View {
    @Bindable var viewModel: EventViewModel
    @State private var cityName: String = ""
    @State private var showMapView = false
    
    // Custom colors
    private let primaryColor = Color.blue
    private let secondaryColor = Color.pink
    private let cardBackground = Color(.systemBackground)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        primaryColor.opacity(0.2),
                        secondaryColor.opacity(0.2),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search section with better spacing
                    searchSection
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                    
                    // Events list with improved card styling
                    eventResultsView
                        .padding(.horizontal, 12)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    mapButton
                }
            }
            .onAppear {
                if let lastSearch = viewModel.getLastSearch() {
                    if let city = lastSearch.cityName, !city.isEmpty {
                        cityName = city
                        viewModel.loadEvents(for: city)
                    } else if let lat = lastSearch.latitude, let lon = lastSearch.longitude {
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        viewModel.loadEvents(for: coordinate)
                        cityName = ""
                    }
                }
            }

            .sheet(isPresented: $showMapView) {
                MapPickerView(viewModel: viewModel)
                    .onDisappear {
                        cityName = ""
                    }
            }
        }
        .accentColor(primaryColor)
    }
    
    // MARK: - Subviews
    
    private var searchSection: some View {
        HStack(spacing: 12) {
            TextField("Search city...", text: $cityName)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit {
                    searchEvents()
                }
                .font(.subheadline)
            
            Button(action: searchEvents) {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.iconOnly)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .disabled(cityName.isEmpty)
        }
    }
    
    private var eventResultsView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if viewModel.events.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach($viewModel.events, id: \.id) { $event in
                            NavigationLink {
                                EventDetailView(event: event, viewModel: viewModel)
                            } label: {
                                EventCardView(event: $event, imageURL: bestImageURL(from: event.images), viewModel: viewModel)
                            }
                        }

                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
    }


    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(viewModel.events.isEmpty && !cityName.isEmpty ?
                 "No events found in \(cityName)" :
                 "Search for events in your city")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    private var mapButton: some View {
        Button {
            showMapView = true
           
        } label: {
            Image(systemName: "map")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
    
    // MARK: - Helper Methods
    
    private var navigationTitle: String {
        if cityName.isEmpty {
            return "Event Explorer"
        } else if viewModel.events.isEmpty {
            return "No Events"
        } else {
            return cityName
        }
    }
    
    private func bestImageURL(from images: [EventImage]) -> URL? {
        // First get the best image that matches our criteria
        guard let bestImage = images
            .filter({ $0.ratio == "16_9" })
            .max(by: { $0.width < $1.width }) else {
            return nil
        }
        
        return URL(string: bestImage.url)
    }
    
    private func searchEvents() {
        viewModel.loadEvents(for: cityName)
        viewModel.saveLastSearch(cityName: cityName)
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

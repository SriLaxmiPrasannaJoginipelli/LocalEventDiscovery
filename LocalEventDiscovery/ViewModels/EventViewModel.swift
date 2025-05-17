//
//  EventViewModel.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//

import Foundation
import SwiftUI
import Observation
import CoreLocation

@Observable
class EventViewModel {
    var events: [Event] = []
    var isLoading = false
    var error: Error?
    private let favouritesKey = "favouriteEventIDs"
    private let searchKey = "searchTitle"
    var favouritesDict: [String: Event] = [:]
    
    private let service = EventService()
    
    init() {
        loadFavouritesDict()
    }
    
    func loadEvents(for city: String) {
        isLoading = true
        error = nil
        getCoordinates(for: city) { coordinate in
            guard let coordinate = coordinate else { return }
            let key = self.getAPIKey()
            let url = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=\(key)&latlong=\(coordinate.latitude),\(coordinate.longitude)"
            
            self.service.fetchEvents(from: url) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        self?.events = response._embedded.events ?? []
                        self?.applySavedFavourites()
                    case .failure(let err):
                        self?.error = err
                    }
                }
            }
        }
    }
    func getCoordinates(for city: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, error in
            guard let location = placemarks?.first?.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
    
    func toggleFavourite(for event: Event) {
        guard let eventId = event.id else { return }
        if events.firstIndex(where: { $0.id == eventId }) != nil {
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index].isFavourite.toggle()
                let isFav = events[index].isFavourite
                updateFavouriteIDs(eventID: eventId, isFavourite: isFav)
                if isFav {
                    favouritesDict[eventId] = events[index]
                } else {
                    favouritesDict.removeValue(forKey: eventId)
                }
            }
        }
    }
    
    var favouritedEvents: [Event] {
        return Array(favouritesDict.values)
    }
    
    private func updateFavouriteIDs(eventID: String, isFavourite: Bool) {
        var favourites = UserDefaults.standard.stringArray(forKey: favouritesKey) ?? []
        
        if isFavourite {
            if !favourites.contains(eventID) {
                favourites.append(eventID)
            }
        } else {
            favourites.removeAll { $0 == eventID }
        }
        
        UserDefaults.standard.set(favourites, forKey: favouritesKey)
        saveFavouritesDict() // Save whole favorite events to disk (optional)
    }
    
    func applySavedFavourites() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: favouritesKey) ?? []
        for index in events.indices {
            if let id = events[index].id {
                events[index].isFavourite = savedIDs.contains(id)
                if events[index].isFavourite {
                    favouritesDict[id] = events[index]
                }
            }
        }
    }
    
    // Add serialization to save/load favouritesDict if needed
    func saveFavouritesDict() {
        if let data = try? JSONEncoder().encode(favouritesDict) {
            UserDefaults.standard.set(data, forKey: "favouritesDict")
        }
    }
    
    func loadFavouritesDict() {
        if let data = UserDefaults.standard.data(forKey: "favouritesDict"),
           let dict = try? JSONDecoder().decode([String: Event].self, from: data) {
            favouritesDict = dict
        }
    }
    
    func saveLastSearch(cityName: String?) {
        let lastSearch = LastSearch(cityName: cityName, latitude: nil, longitude: nil)
        if let data = try? JSONEncoder().encode(lastSearch) {
            UserDefaults.standard.set(data, forKey: "lastSearch")
        }
    }
    
    func saveLastSearch(coordinate: CLLocationCoordinate2D) {
        let lastSearch = LastSearch(cityName: nil, latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let data = try? JSONEncoder().encode(lastSearch) {
            UserDefaults.standard.set(data, forKey: "lastSearch")
        }
    }
    
    func getLastSearch() -> LastSearch? {
        guard let data = UserDefaults.standard.data(forKey: "lastSearch") else { return nil }
        return try? JSONDecoder().decode(LastSearch.self, from: data)
    }
    
    func getAPIKey() -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["TicketmasterAPIKey"] as? String else {
            fatalError("Missing API key")
        }
        return key
    }
}


extension EventViewModel {
    func loadEvents(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        error = nil
        
        let url = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=I2YdyIbXQTTYIawWc4ZOzq8srr2QW1Ic&latlong=\(coordinate.latitude),\(coordinate.longitude)"
        
        self.service.fetchEvents(from: url) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.events = response._embedded.events ?? []
                    self?.applySavedFavourites()
                case .failure(let err):
                    self?.error = err
                }
            }
        }
    }
}


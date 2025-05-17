//
//  FavouritesView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/15/25.
//

import SwiftUI

struct FavouritesView: View {
    @State var isFavourite : Bool?
    @Bindable var viewModel : EventViewModel
    @State private var displayedFavourites: [Event] = []
    var body: some View {
        NavigationStack{
            List{
                if(viewModel.favouritedEvents.isEmpty){
                    EmptyFavouriteCardView()
                }
                ForEach(displayedFavourites, id: \.id) { event in
                    Text(event.name ?? "No event name found")
                        .font(.headline)
                }
                .onDelete { IndexSet in
                    deleteItems(at: IndexSet)
                }
                
            }
            .toolbar {
                EditButton()
                    .disabled(viewModel.favouritedEvents.isEmpty)
            }
            .onAppear{
                viewModel.applySavedFavourites()
                displayedFavourites = viewModel.favouritedEvents
            }
        }
    }
    private func unfavourite(at offsets: IndexSet) {
            for index in offsets {
                let event = displayedFavourites[index]

                // Update EventViewModel
                if let i = viewModel.events.firstIndex(where: { $0.id == event.id }) {
                    viewModel.events[i].isFavourite = false
                    removeFromSavedFavourites(id: event.id)
                }
            }

            // Remove from local source to keep SwiftUI's List consistent
            displayedFavourites.remove(atOffsets: offsets)
        }

        private func removeFromSavedFavourites(id: String?) {
            guard let id else { return }
            var saved = UserDefaults.standard.stringArray(forKey: "favouriteEventIDs") ?? []
            saved.removeAll { $0 == id }
            UserDefaults.standard.set(saved, forKey: "favouriteEventIDs")
        }
    
    private func deleteItems(at offsets: IndexSet) {
        let eventsToUnfavourite = offsets.compactMap { index in
            displayedFavourites.indices.contains(index) ? displayedFavourites[index] : nil
        }

        // Update persistent store and in-memory dictionary
        for event in eventsToUnfavourite {
            removeFromSavedFavourites(id: event.id)
            viewModel.favouritesDict[event.id ?? ""] = nil
            viewModel.toggleFavourite(for: event) // if this handles isFavourite flag
        }

        // Update UI
        displayedFavourites.remove(atOffsets: offsets)
    }

}

struct EmptyFavouriteCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 16) {
                Image(systemName: "heart.slash.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.red.opacity(0.7))
                
                Text("No favourite events found")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("Tap the heart icon on an event to save it here.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding()
        }
        .frame(width: 320, height: 220)
        .padding()
    }
}




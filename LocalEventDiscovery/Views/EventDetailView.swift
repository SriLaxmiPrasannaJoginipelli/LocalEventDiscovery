//
//  EventDetailView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/16/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Bindable var viewModel: EventViewModel

    // Best image URL selector
    private var imageURL: URL? {
        event.images
            .filter { $0.ratio == "16_9" }
            .max(by: { $0.width < $1.width })
            .flatMap { URL(string: $0.url) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Event Image
                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                }

                // Name
                Text(event.name ?? "Event Name")
                    .font(.title)
                    .fontWeight(.bold)

                // Type & Genre
                if let type = event.type {
                    Text("Type: \(type.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let genre = event.classifications.first?.genre?.name {
                    Text("Genre: \(genre)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Total Upcoming Events
                if let total = event.upcomingEvents?._total {
                    Text("Upcoming Events: \(total)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                // External Links
                if let urlString = event.url, let url = URL(string: urlString) {
                    SwiftUI.Link(destination: url) {
                        Text("View on Ticketmaster")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }


                if let twitter = event.externalLinks?.twitter?.first?.url,
                   let url = URL(string: twitter) {
                    SwiftUI.Link("Twitter", destination: url)
                    
                }

                if let instagram = event.externalLinks?.instagram?.first?.url,
                   let url = URL(string: instagram) {
                    SwiftUI.Link("Instagram", destination: url)
                }

                if let homepage = event.externalLinks?.homepage?.first?.url,
                   let url = URL(string: homepage) {
                    SwiftUI.Link("Website", destination: url)
                }

                Divider()

                // Favourite Button
                Button {
                    viewModel.toggleFavourite(for: event)
                } label: {
                    Label(event.isFavourite ? "Favourited" : "Add to Favourites",
                          systemImage: event.isFavourite ? "heart.fill" : "heart")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(event.isFavourite ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }

            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


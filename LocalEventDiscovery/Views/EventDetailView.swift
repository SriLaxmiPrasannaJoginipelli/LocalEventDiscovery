//
//  EventDetailView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/16/25.
//

import SwiftUI

struct EventDetailView: View {
    @Binding var event: Event
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
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Event Image
                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.1)
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
                    .shadow(radius: 4)
                }

                // MARK: - Event Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.name ?? "Event Name")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(3)

                    if let type = event.type {
                        InfoRow(label: "Type", value: type.capitalized)
                    }

                    if let genre = event.classifications.first?.genre?.name {
                        InfoRow(label: "Genre", value: genre)
                    }

                    if let total = event.upcomingEvents?._total {
                        InfoRow(label: "Upcoming Events", value: "\(total)")
                    }
                }

                Divider()

                // MARK: - External Links
                VStack(alignment: .leading, spacing: 12) {
                    Text("External Links")
                        .font(.headline)

                    if let urlString = event.url, let url = URL(string: urlString) {
                        ExternalLinkRow(title: "View on Ticketmaster", url: url)
                    }

                    if let twitter = event.externalLinks?.twitter?.first?.url,
                       let url = URL(string: twitter) {
                        ExternalLinkRow(title: "Twitter", url: url)
                    }

                    if let instagram = event.externalLinks?.instagram?.first?.url,
                       let url = URL(string: instagram) {
                        ExternalLinkRow(title: "Instagram", url: url)
                    }

                    if let homepage = event.externalLinks?.homepage?.first?.url,
                       let url = URL(string: homepage) {
                        ExternalLinkRow(title: "Website", url: url)
                    }
                }

                Divider()

                // MARK: - Favourite Button
                Button {
                    viewModel.toggleFavourite(for: event)
                } label: {
                    Label(
                        event.isFavourite ? "Favourited" : "Add to Favourites",
                        systemImage: event.isFavourite ? "heart.fill" : "heart"
                    )
                    .font(.headline)
                    .foregroundColor(event.isFavourite ? .red : .blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(event.isFavourite ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                if let urlString = event.url, let url = URL(string: urlString) {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Event")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                }


            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private struct InfoRow: View {
        let label: String
        let value: String

        var body: some View {
            HStack(alignment: .top) {
                Text("\(label):")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }

    private struct ExternalLinkRow: View {
        let title: String
        let url: URL

        var body: some View {
            SwiftUI.Link(destination: url) {
                HStack {
                    Text(title)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }


}


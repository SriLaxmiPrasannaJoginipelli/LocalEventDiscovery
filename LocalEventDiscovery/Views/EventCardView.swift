//
//  EventCardView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//


import SwiftUI

struct EventCardView: View {
    @Binding var event: Event
    @State var imageURL: URL?
    @Bindable var viewModel: EventViewModel

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.name ?? "Untitled Event")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let type = event.type {
                    Text(type.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let genre = event.classifications.first?.genre?.name {
                    Text(genre)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

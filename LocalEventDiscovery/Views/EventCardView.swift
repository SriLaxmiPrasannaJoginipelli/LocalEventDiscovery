//
//  EventCardView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//


import SwiftUI

struct EventCardView: View {
    let event: Event
    @State var imageURL: URL?
    @Bindable var viewModel: EventViewModel

    var body: some View {
        ZStack {
            // Animated Background behind content only
            CustomCircleView()
                .offset(y: -60)
                .zIndex(0)

            VStack(spacing: 16) {
                imageSection
                    .zIndex(1)

                VStack(alignment: .leading, spacing: 8) {
                    Text(event.name ?? "Event")
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if let type = event.type {
                        Label(type.capitalized, systemImage: "tag")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    if let genre = event.classifications.first?.genre?.name {
                        Label(genre, systemImage: "ticket")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    if let url = event.url {
                        HStack {
                            Image(systemName: "link")
                            Text("More info")
                                .underline()
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .onTapGesture {
                            if let url = URL(string: url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .zIndex(1)

                Spacer()

                HStack {
                    Button {
                        viewModel.toggleFavourite(for: event)
                    } label: {
                        Image(systemName: event.isFavourite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(event.isFavourite ? .red : .white)
                            .padding(12)
                            .background(Circle().fill(.ultraThinMaterial))
                    }

                    Spacer()

                    if let url = URL(string: event.url ?? "") {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                }
                .padding(.horizontal)
                .zIndex(1)
            }
            .padding()
        }
        .frame(width: 340, height: 500)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.6))
                .blur(radius: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(30)
        .shadow(radius: 10)
    }

    private var imageSection: some View {
        ZStack {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 180)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(20)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(30)
                        .foregroundColor(.white.opacity(0.5))
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

struct CustomCircleView: View {
    @State private var isAnimated = false

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.indigo.opacity(0.4), Color.pink.opacity(0.4)],
                    startPoint: isAnimated ? .topLeading : .bottomLeading,
                    endPoint: isAnimated ? .bottomTrailing : .topTrailing
                )
            )
            .scaleEffect(isAnimated ? 1.05 : 0.95)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    isAnimated.toggle()
                }
            }
            .frame(width: 360, height: 360)
            .blur(radius: 40)
            .opacity(0.4)
    }
}

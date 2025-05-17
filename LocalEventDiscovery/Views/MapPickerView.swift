//
//  MapPickerView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/15/25.
//


import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapPickerView: View {
    // MARK: - Properties
    @Bindable var viewModel : EventViewModel
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    private let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            mapView
            locationStatusView
            actionButton
        }
        .padding()
        .navigationTitle("Pick a Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cameraPosition = .region(defaultRegion)
        }
    }
    
    // MARK: - Subviews
    private var mapView: some View {
        MapReader { proxy in
            Map(position: $cameraPosition, interactionModes: .all) {
                if let coordinate = selectedCoordinate {
                    Marker(coordinate: coordinate) {
                        Image(systemName: "mappin.circle.fill")
                    }
                    .tint(.red)
                }
            }
            .onTapGesture { screenPoint in
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    withAnimation {
                        selectedCoordinate = coordinate
                    }
                }
            }
        }
        .frame(height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
    
    private var locationStatusView: some View {
        Group {
            if let coordinate = selectedCoordinate {
                VStack(spacing: 4) {
                    Text("Selected Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(
                        String(
                            format: "%.6f, %.6f",
                            coordinate.latitude,
                            coordinate.longitude
                        )
                    )
                    .font(.footnote.monospaced())
                }
            } else {
                Label("Tap the map to select a location", systemImage: "mappin.and.ellipse")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var actionButton: some View {
        Button {
            if let coordinate = selectedCoordinate {
                viewModel.loadEvents(for: coordinate)
                viewModel.saveLastSearch(coordinate: coordinate)
                dismiss()
            }
        } label: {
            Label("Find Events Here", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedCoordinate == nil)
    }
    
}

// MARK: - Equatable Extension for Coordinate
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Preview
//#Preview {
//    NavigationStack {
//        MapPickerView()
//    }
//}

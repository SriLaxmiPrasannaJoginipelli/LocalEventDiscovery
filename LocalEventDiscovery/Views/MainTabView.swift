//
//  MainTabView.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/15/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var viewModel = EventViewModel()
    var body: some View {
        TabView {
            EventsListView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FavouritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favourites", systemImage: "heart")
                }
        }
    }
}


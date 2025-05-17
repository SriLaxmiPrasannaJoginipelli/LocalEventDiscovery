//
//  LocalEventDiscoveryApp.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//

import SwiftUI

@main
struct LocalEventDiscoveryApp: App {
    @State private var viewModel = EventViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(viewModel: viewModel)
                
        }
    }
}

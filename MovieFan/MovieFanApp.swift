//
//  MovieFanApp.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import SwiftUI

@main
struct MovieFanApp: App {
    let viewModel = MoviesViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MoviesView()
                    .environmentObject(viewModel)
            }
        }
    }
}

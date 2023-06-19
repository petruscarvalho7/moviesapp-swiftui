//
//  ContentView.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    var body: some View {
        List {
            Section(header: Text("Popular Movies")) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(destination:
                                    MovieDetailsView(movie: movie)) {
                        MovieCardView(movie: movie)
                    }
                }
            }
        }
        .navigationTitle("Movies")
        .onAppear {
            viewModel.getMovies()
        }
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
            .environmentObject(MoviesViewModel())
    }
}

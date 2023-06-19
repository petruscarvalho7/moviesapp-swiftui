//
//  MovieDetailsView.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 19/06/23.
//

import SwiftUI

struct MovieDetailsView: View {
    var movie: Movie
    
    var body: some View {
        ScrollView {
            VStack {
                Text(movie.title)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                let url = URL(string: movie.getLargeImageUrl())
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    Image("blue_square")
                        .resizable()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                }
                Text("Released: \(movie.releaseDate)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text(movie.overview)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                    .padding()
                Spacer()
            }
            .accessibilityLabel("Movie Details")
        }
        .navigationTitle("Details")
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movie: Movie(
            id: 1,
            title: "The Exorcist",
            releaseDate: "1979-06-06",
            imageUrlSuffix: "/1.jpb",
            overview: "The Exorcist is a terror/horror filme. The film is set in United States."
        ))
    }
}

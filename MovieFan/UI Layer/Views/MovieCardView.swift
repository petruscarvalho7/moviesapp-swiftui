//
//  MovieCardView.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import SwiftUI

struct MovieCardView: View {
    var movie: Movie

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(movie.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(movie.releaseDate)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            }
            Spacer()
            let url = URL(string: movie.getThumbnailImageUrl())
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            } placeholder: {
                Image("blue_square")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
        }
        .padding()
    }
}

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCardView(movie: Movie(
            id: 1,
            title: "The Exorcist",
            releaseDate: "1979-06-06",
            imageUrlSuffix: "/1.jpb",
            overview: "The Exorcist is a terror/horror filme. The film is set in United States."
        ))
    }
}

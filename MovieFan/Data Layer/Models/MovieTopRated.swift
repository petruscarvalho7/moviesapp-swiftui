//
//  MovieTopRated.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 21/06/23.
//

import Foundation

struct MovieTopRatedRootResult: Codable {
    let page: Int
    let moviesTopRated: [MovieTopRated]
    
    enum CodingKeys: String, CodingKey {
        case page
        case moviesTopRated = "results"
    }
}

struct MovieTopRated: Codable, Identifiable {
    struct Constants {
        static let baseImageUrl = "https://image.tmdb.org/t/p/"
        static let logoSize = "w45"
        static let largeSize = "w500"
    }
    
    let id: Int
    let title: String
    let popularity: Double
    let voteCount: Int
    let voteAverage: Double
    let posterImage: String
    
    func getThumbnailImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.logoSize)\(posterImage)"
    }
    
    func getLargeImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.largeSize)\(posterImage)"
    }
    
    // mock calculation
    func minVote() -> Double {
        return voteAverage / Double.random(in: 2...3)
    }
    
    // mock calculation
    func maxVote() -> Double {
        return voteAverage * Double.random(in: 2...3)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "original_title"
        case popularity
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case posterImage = "poster_path"
    }
}

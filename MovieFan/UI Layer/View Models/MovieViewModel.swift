//
//  MovieViewModel.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var moviesTopRated: [MovieTopRated] = []
    @Published private(set) var error: DataError? = nil
    
    private let apiService: MovieAPILogic
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
    }
    
    func getMovies() {
        apiService.getMovies() { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movies = movies ?? []
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    func getMoviesTopRated() {
        apiService.getTopRatedMovies { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error
            case .success(let moviesTopRated):
                self?.moviesTopRated = moviesTopRated ?? []
            }
        }
    }
    
    func getMovieRatingsVoteAverage() -> Double {
        let voteAverageList = moviesTopRated.prefix(10).map { $0.voteAverage }
        let sumAverage = voteAverageList.reduce(0, +) / 10
        return sumAverage
    }
}

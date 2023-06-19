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
}

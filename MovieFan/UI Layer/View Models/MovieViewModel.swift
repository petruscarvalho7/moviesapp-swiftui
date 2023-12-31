//
//  MovieViewModel.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import Foundation
import Combine
import Network

class MoviesViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var moviesTopRated: [MovieTopRated] = []
    @Published private(set) var error: DataError? = nil
    
    private var networkConnectivity: NWPathMonitor
    
    private let apiService: MovieAPILogic
    
    // Core Data
    private var persistentController: MoviePersistentController
    private var persistentTopRatedController: MovieTopRatedPersistentController
    
    init(apiService: MovieAPILogic = MovieAPI(),
         persistentController: MoviePersistentController = MoviePersistentController(),
         networkConnectivity: NWPathMonitor = NWPathMonitor(),
         persistentTopRatedController: MovieTopRatedPersistentController = MovieTopRatedPersistentController()
    ) {
        self.apiService = apiService
        self.persistentController = persistentController
        self.networkConnectivity = networkConnectivity
        self.persistentTopRatedController = persistentTopRatedController
        
        // network connection listener
        networkConnectivity.start(queue: DispatchQueue.global(qos: .userInitiated))
    }
    
    func getMovies() {
        switch networkConnectivity.currentPath.status {
        case .satisfied: // connected!
            apiService.getMovies() { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies = movies ?? []
                    
                    self?.persistentController.updateAndAddData(movies: movies)
                case .failure(let error):
                    self?.error = error
                }
            }
        default:
            self.persistentController.getDBDataToMovieData { [weak self] result in
                switch result {
                case.success(let movies):
                    self?.movies = movies ?? []
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func getMoviesTopRated() {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            apiService.getTopRatedMovies { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                case .success(let moviesTopRated):
                    self?.moviesTopRated = moviesTopRated ?? []
                    
                    self?.persistentTopRatedController.updateAndAddDataMoviesTopRated(movies: moviesTopRated)
                }
            }
        default:
            self.persistentTopRatedController.getDBDataToMovieTopRatedData { [weak self] result in
                switch result {
                case.success(let moviesTopRated):
                    self?.moviesTopRated = moviesTopRated ?? []
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func getMovieRatingsVoteAverage() -> Double {
        let voteAverageList = moviesTopRated.prefix(10).map { $0.voteAverage }
        let sumAverage = voteAverageList.reduce(0, +) / 10
        return sumAverage
    }
}

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
    
    private var networkConnectivity = NWPathMonitor()
    
    private let apiService: MovieAPILogic
    
    // Core Data
    private var persistentController = MoviePersistentController()
    private var movieFetchRequest = MovieCoreData.fetchRequest()
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
        networkConnectivity.start(queue: DispatchQueue.global(qos: .userInitiated))
    }
    
    func getMovies() {
        switch networkConnectivity.currentPath.status {
        case .satisfied: // connected!
            apiService.getMovies() { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies = movies ?? []
                    
                    guard let movies = movies, !movies.isEmpty else { return }
                    var moviesDict: [Int: Movie] = [:]

                    for movie in movies {
                        moviesDict[movie.id] = movie
                    }
                    
                    // 1. get all core data movies (find any existing movies in CoreData)
                    guard let movieFetchRequest = self?.movieFetchRequest else { return }
                    movieFetchRequest.predicate = NSPredicate(
                        format: "id IN %@",
                        Array(moviesDict.keys)
                    )
                    
                    // 2. make a fetchRequest using predicate
                    guard let manageObjcContext = self?.persistentController.persistentContainer.viewContext else { return }
                    let moviesDBList = try? manageObjcContext.fetch(movieFetchRequest)
                    
                    var moviesIdListInDB: [Int] = []
                    
                    // 3. update all match movies
                    guard let moviesDBList = moviesDBList else { return }
                    for movieDB in moviesDBList {
                        moviesIdListInDB.append(Int(movieDB.id))
                        if let movie = moviesDict[Int(movieDB.id)] {
                            if movieDB.overview != movie.overview {
                                movieDB.setValue(movie.overview, forKey: "overview")
                            }
                            if movieDB.imageUrlSuffix != movie.imageUrlSuffix {
                                movieDB.setValue(movie.imageUrlSuffix, forKey: "imageUrlSuffix")
                            }
                            if movieDB.releaseDate != movie.releaseDate {
                                movieDB.setValue(movie.releaseDate, forKey: "releaseDate")
                            }
                            if movieDB.title != movie.title {
                                movieDB.setValue(movie.title, forKey: "title")
                            }
                        }
                    }
                    
                    // 4. add new objs on local DB
                    for movie in movies {
                        if !moviesIdListInDB.contains(movie.id) {
                            let movieDB = MovieCoreData(context: manageObjcContext)
                            movieDB.id = Int64(movie.id)
                            movieDB.title = movie.title
                            movieDB.releaseDate = movie.releaseDate
                            movieDB.overview = movie.overview
                            movieDB.imageUrlSuffix = movie.imageUrlSuffix
                            movieDB.largeImageUrl = movie.getLargeImageUrl()
                            movieDB.thumbnailImageUrl = movie.getThumbnailImageUrl()
                        }
                    }
                    
                    // 5. save db
                    try? manageObjcContext.save()
                case .failure(let error):
                    self?.error = error
                }
            }
        default:
            do {
                let moviesDBList = try persistentController.persistentContainer.viewContext
                    .fetch(movieFetchRequest)
                var moviesToList: [Movie] = []
                for movieDB in moviesDBList {
                    let movie = Movie(
                        id: Int(movieDB.id),
                        title: movieDB.title ?? "",
                        releaseDate: movieDB.releaseDate ?? "",
                        imageUrlSuffix: movieDB.imageUrlSuffix ?? "",
                        overview: movieDB.overview ?? ""
                    )
                    moviesToList.append(movie)
                }
                movies = moviesToList
            } catch {
                self.error = .coreDataError("Biggest zebra happened during coreData flow.")
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
                }
            }
        default:
            // todo get db data
            break
        }
    }
    
    func getMovieRatingsVoteAverage() -> Double {
        let voteAverageList = moviesTopRated.prefix(10).map { $0.voteAverage }
        let sumAverage = voteAverageList.reduce(0, +) / 10
        return sumAverage
    }
}

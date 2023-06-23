//
//  MovieTopRatedPersistentController.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 23/06/23.
//

import Foundation
import CoreData

class MovieTopRatedPersistentController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieFan")
    
    private var movieFetchRequest = MovieTopRatedCoreData.fetchRequest()
    
    private struct Constants {
        static let sortTitle = NSSortDescriptor(key: "title", ascending: true)
    }
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    
    fileprivate func sortData() {
        // sort
        movieFetchRequest.sortDescriptors = [Constants.sortTitle]
    }
    
    func getDBDataToMovieTopRatedData(completion: @escaping (MovieTopRatedAPIResponse)) {
        do {
            sortData()

            let moviesDBList = try persistentContainer.viewContext
                .fetch(movieFetchRequest)
            var moviesToList: [MovieTopRated] = []
            for movieDB in moviesDBList {
                let movie = MovieTopRated(
                    id: Int(movieDB.id),
                    title: movieDB.title ?? "",
                    popularity: movieDB.popularity,
                    voteCount: Int(movieDB.voteCount),
                    voteAverage: movieDB.voteAverage,
                    posterImage: movieDB.posterImage ?? ""
                )
                moviesToList.append(movie)
            }
            completion(.success(moviesToList))
        } catch {
            completion(.failure(.coreDataError("(MovieTopRated) Biggest zebra happened during coreData flow.")))
        }
    }
    
    func updateAndAddDataMoviesTopRated(movies: [MovieTopRated]?) {
        guard let movies = movies, !movies.isEmpty else { return }

        var moviesDict: [Int: MovieTopRated] = [:]

        for movie in movies {
            moviesDict[movie.id] = movie
        }
        
        // 1. get all core data movies (find any existing moviesTopRated in CoreData)
        movieFetchRequest.predicate = NSPredicate(
            format: "id IN %@",
            Array(moviesDict.keys)
        )

        sortData()
        
        // 2. make a fetchRequest using predicate
        let manageObjcContext = self.persistentContainer.viewContext
        let moviesDBList = try? manageObjcContext.fetch(movieFetchRequest)
        
        var moviesIdListInDB: [Int] = []
        
        // 3. update all match movies
        guard let moviesDBList = moviesDBList else { return }
        for movieDB in moviesDBList {
            moviesIdListInDB.append(Int(movieDB.id))
            if let movie = moviesDict[Int(movieDB.id)] {
                if movieDB.title != movie.title {
                    movieDB.setValue(movie.title, forKey: "title")
                }
                if movieDB.popularity != movie.popularity {
                    movieDB.setValue(movie.popularity, forKey: "popularity")
                }
                if movieDB.voteAverage != movie.voteAverage {
                    movieDB.setValue(movie.voteAverage, forKey: "voteAverage")
                }
                if movieDB.voteCount != movie.voteCount {
                    movieDB.setValue(movie.voteCount, forKey: "voteCount")
                }
                if movieDB.posterImage != movie.posterImage {
                    movieDB.setValue(movie.posterImage, forKey: "posterImage")
                }
            }
        }
        
        // 4. add new objs on local DB
        for movie in movies {
            if !moviesIdListInDB.contains(movie.id) {
                let movieDB = MovieTopRatedCoreData(context: manageObjcContext)
                movieDB.id = Int64(movie.id)
                movieDB.title = movie.title
                movieDB.popularity = movie.popularity
                movieDB.voteAverage = movie.voteAverage
                movieDB.voteCount = Int64(movie.voteCount)
                movieDB.posterImage = movie.posterImage
            }
        }
        
        // 5. save db
        try? manageObjcContext.save()
    }
}

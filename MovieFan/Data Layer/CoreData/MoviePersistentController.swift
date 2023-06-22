//
//  MoviePersistentController.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 21/06/23.
//

import Foundation
import CoreData

class MoviePersistentController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieFan")
    
    private var movieFetchRequest = MovieCoreData.fetchRequest()
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    
    func getDBDataToMovieData(completion: @escaping (MovieAPIResponse)) {
        do {
            let moviesDBList = try persistentContainer.viewContext
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
            completion(.success(moviesToList))
        } catch {
            completion(.failure(.coreDataError("Biggest zebra happened during coreData flow.")))
        }
    }
    
    func updateAndAddData(movies: [Movie]?) {
        guard let movies = movies, !movies.isEmpty else { return }

        var moviesDict: [Int: Movie] = [:]

        for movie in movies {
            moviesDict[movie.id] = movie
        }
        
        // 1. get all core data movies (find any existing movies in CoreData)
        movieFetchRequest.predicate = NSPredicate(
            format: "id IN %@",
            Array(moviesDict.keys)
        )
        
        // 2. make a fetchRequest using predicate
        let manageObjcContext = self.persistentContainer.viewContext
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
            }
        }
        
        // 5. save db
        try? manageObjcContext.save()
    }
    
}

//
//  MovieAPI.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import Foundation
import Alamofire

typealias MovieAPIResponse = (Swift.Result<[Movie]?, DataError>) -> Void
typealias MovieTopRatedAPIResponse = (Swift.Result<[MovieTopRated]?, DataError>) -> Void

/// API interface to retrieve movies
protocol MovieAPILogic {
    func getMovies(completion: @escaping (MovieAPIResponse))
    func getTopRatedMovies(completion: @escaping (MovieTopRatedAPIResponse))
}

class MovieAPI: MovieAPILogic {
    /// Movie API URL returning list of movies with details
    private struct Constants {
        static let apiKey = "80120157161f4f3fe777f9be42095902"
        static let languageLocale = "en-US"
        // base urls
        static let moviesURLBase = "https://api.themoviedb.org/3/movie/"
        static let apiLanguagePageInfo = "api_key=\(apiKey)&language=\(languageLocale)&page=\(pageValue)"
        
        // rest apis
        static let moviesPopular = moviesURLBase + "popular?" + apiLanguagePageInfo
        static let moviesTopRated = moviesURLBase + "top_rated?" + apiLanguagePageInfo
        
        // params and types
        static let pageValue = 1
        static let rParameter = "r"
        static let json = "json"
    }
    
    func getMovies(completion: @escaping (MovieAPIResponse)) {
        // this prevents AF retrieving cached responses
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(Constants.moviesPopular,
                   method: .get,
                   encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: MovieRootResult.self) { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(.networkingError(error.localizedDescription)))
            case .success(let moviesListResult):
                completion(.success(moviesListResult.movies))
            }
        }
    }
    
    func getTopRatedMovies(completion: @escaping (MovieTopRatedAPIResponse)) {
        // this prevents AF retrieving cached responses
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(Constants.moviesTopRated,
                   method: .get,
                   encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: MovieTopRatedRootResult.self) { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(.networkingError(error.localizedDescription)))
            case .success(let moviesListResult):
                completion(.success(moviesListResult.moviesTopRated))
            }
        }
    }
}

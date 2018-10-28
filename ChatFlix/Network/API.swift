//
//  API.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 8/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation
import Moya

class API {
    static let apiKey = "613821cc4edc2abf60fcfcd853f5d075"
    static let provider = MoyaProvider<MovieApi>()
    
    static func getNewMovies(page: Int, completion: @escaping ([Movie])->()) {
        provider.request(.newMovies(page: page)) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(APIResults.self, from: response.data)
                    completion(results.movies)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    static func getTopRated(page: Int, completion: @escaping ([Movie?])->()) {
        provider.request(.topRated(page: page)) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(APIResults.self, from: response.data)
                    completion(results.movies)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    static func getRecommendations(id: Int, completion: @escaping ([Movie]?)->()) {
        provider.request(.reco(id: id)) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(APIResults.self, from: response.data)
                    completion(results.movies)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    static func getVideos(id: Int, completion: @escaping ([VideoKey])->()) {
        provider.request(.video(id: id)) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(VideoResults.self, from: response.data)
                    completion(results.details)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    static func searchMovies(query: String, completion: @escaping ([Movie]?) -> ()) {
        provider.request(.searchMovies(query: query)) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(APIResults.self, from: response.data)
                    completion(results.movies)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    static func getMovie(id: Int, completion: @escaping (Movie?) -> ()) {
        provider.request(.movie(id: id)) { result in
            switch result {
            case let .success(response):
                do {
                    let movie = try JSONDecoder().decode(Movie.self, from: response.data)
                    completion(movie)
                } catch let err {
                    print(err)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

//
//  MovieApi.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 8/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Moya

enum MovieApi {
    case reco(id:Int)
    case topRated(page:Int)
    case newMovies(page:Int)
    case video(id:Int)
    case searchMovies(query:String)
    case movie(id: Int)
}

extension MovieApi: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: "https://api.themoviedb.org/3/") else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .reco(let id):
            return "movie/\(id)/recommendations"
        case .topRated:
            return "movie/popular"
        case .newMovies:
            return "movie/now_playing"
        case .video(let id):
            return "movie/\(id)/videos"
        case .searchMovies:
            return "search/movie"
        case .movie(let id):
            return "movie/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .reco, .topRated, .newMovies, .video, .searchMovies, .movie:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .reco(let id), .video(let id), .movie(let id):
            return Data("{\"id\": \(id)}".utf8)
        case .newMovies(let page), .topRated(let page):
            return Data("{\"page\": \(page)}".utf8)
        case .searchMovies(let query):
            return Data("{\"query\": \(query)}".utf8)
        }
    }
    
    var task: Task {
        switch self {
        case .reco, .video, .movie:
            return .requestParameters(parameters: ["api_key": API.apiKey], encoding: URLEncoding.queryString)
        case .topRated(let page), .newMovies(let page):
            return .requestParameters(parameters: ["page": page, "api_key": API.apiKey], encoding: URLEncoding.queryString)
        case .searchMovies(let query):
            return .requestParameters(parameters: ["api_key": API.apiKey, "query": query, "page": 1], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}

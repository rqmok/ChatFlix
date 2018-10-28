//
//  MovieCollection.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 11/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import Foundation
import Kingfisher

class MovieCollection {
    private var newMovies: [Movie]
    private var newMovieImages: [ImageResource]
    
    private var topRatedMovies: [Movie]
    private var topRatedMovieImages: [ImageResource]
    
    private var searchedMovies: [Movie]
    private var searchedImages: [ImageResource]
    
    init() {
        newMovies = []
        newMovieImages = []
        
        topRatedMovies = []
        topRatedMovieImages = []
        
        searchedMovies = []
        searchedImages = []
    }
    
    // Begin Functions for New Movies
    func getNewMovies() -> [Movie] {
        return newMovies
    }
    
    func addNewMovie(movie: Movie) {
        // Do not add a movie without posterpath
        guard let posterPath = movie.posterPath else {
            return
        }
        
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        let resource = ImageResource(downloadURL: url!, cacheKey: String(movie.id))
        
        newMovies.append(movie)
        newMovieImages.append(resource)
    }
    
    func getNewMoviesCount() -> Int {
        return newMovies.count
    }
    
    func getNewMovie(index: Int) -> Movie {
        return newMovies[index]
    }
    
    func getNewMovieImages() -> [ImageResource] {
        return newMovieImages
    }
    
    func getNewMovieImage(index: Int) -> ImageResource {
        return newMovieImages[index]
    }
    // End Functions for New Movies
    
    // Begin Functions for Top Rated Movies
    func getTopRatedMovies() -> [Movie] {
        return topRatedMovies
    }
    
    func addTopRatedMovie(movie: Movie) {
        // Do not add a movie without posterpath
        guard let posterPath = movie.posterPath else {
            return
        }
        
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        let resource = ImageResource(downloadURL: url!, cacheKey: String(movie.id))
        
        topRatedMovies.append(movie)
        topRatedMovieImages.append(resource)
    }
    
    func getTopRatedMoviesCount() -> Int {
        return topRatedMovies.count
    }
    
    func getTopRatedMovie(index: Int) -> Movie {
        return topRatedMovies[index]
    }
    
    func getTopRatedMovieImages() -> [ImageResource] {
        return topRatedMovieImages
    }
    
    func getTopRatedMovieImage(index: Int) -> ImageResource {
        return topRatedMovieImages[index]
    }
    // End Functions for Top Rated Movies
    
    // Begin Functions for Searching Movies
    func getSearchedMovies() -> [Movie] {
        return searchedMovies
    }
    
    func getSearchedImages() -> [ImageResource] {
        return searchedImages
    }
    
    func searchMovies(query: String) {
        // Reset the search lists
        searchedMovies = []
        searchedImages = []
        
        // Search through new movies
        for i in 0..<newMovies.count {
            let movie = newMovies[i]
            if movie.title.lowercased().contains(query.lowercased()) {
                searchedMovies.append(movie)
                searchedImages.append(newMovieImages[i])
            }
        }
        
        // Search through popular movies
        for i in 0..<topRatedMovies.count {
            let movie = topRatedMovies[i]
            if movie.title.lowercased().contains(query.lowercased()) {
                if (containsMovie(movies: searchedMovies, movie: movie) == false) {
                    searchedMovies.append(movie)
                    searchedImages.append(topRatedMovieImages[i])
                }
            }
        }
    }
    
    private func containsMovie(movies: [Movie], movie: Movie) -> Bool {
        for mov in movies {
            if mov.id == movie.id {
                return true
            }
        }
        
        return false
    }
    // End Functions for Searching Movies
}

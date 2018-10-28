//
//  MoviesViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 11/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Kingfisher

class MoviesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    
    // Stores search results
    private var searchedMovies: [Movie] = []
    private var searchedImages: [ImageResource] = []
    
    // Hold a collection of movies
    private var moviesCollection: MovieCollection = MovieCollection()
    
    // Identifier for movie cell with image
    let cellReuseIdentifier = "movieCell"
    
    // Identifier for movie section header
    let headerReuseIdentifier = "movieHeader"
    
    // Sections for Collection View
    let NUM_SECTIONS = 1, SECTION_NEW_MOVIES = 0, SECTION_TOP_RATED_MOVIES = 1
    
    // Store the movie whose details need to be shown
    private var movieToShow: Movie?
    private var movieImageToShow: ImageResource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set collection view delegate and datasource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Create and add a search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies Database"
        searchController.searchBar.delegate = self        
        searchController.providesPresentationContextTransitionStyle = true
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        // Download movies data
        self.loadMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadMovies() {
        // Download new movies
        API.getNewMovies(page: 1, completion: { movies in
            for movie in movies {
                self.moviesCollection.addNewMovie(movie: movie)
            }
            
            // Reload collection view after all movies have been downloaded
            self.collectionView.reloadData()
        })
        
        // Download top rated movies
        API.getTopRated(page: 1, completion: { movies in
            for movie in movies {
                self.moviesCollection.addTopRatedMovie(movie: movie!)
            }
            
            // Reload collection view
            self.collectionView.reloadData()
        })
    }
    
    private func isSearching() -> Bool {
        if searchedMovies.count > 0 {
            return true
        }
        
        return false
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    private func pushDetailsController() {
        self.performSegue(withIdentifier: "movieDetailsSegue", sender: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetailsSegue" {
            let detailsController = segue.destination as! MovieDetailsViewController
            detailsController.movie = self.movieToShow
            detailsController.movieImage = self.movieImageToShow
        }
    }

}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isSearching() {
            return 1
        } else {
            return NUM_SECTIONS
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching() {
            return searchedMovies.count
        }
        
        switch section {
        case SECTION_NEW_MOVIES:
            return moviesCollection.getNewMoviesCount()
        case SECTION_TOP_RATED_MOVIES:
            return moviesCollection.getTopRatedMoviesCount()
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        
        let resource =  { () -> ImageResource in
            if self.isSearching() {
                return self.searchedImages[indexPath.row]
            }
            
            if indexPath.section == self.SECTION_NEW_MOVIES {
                return self.moviesCollection.getNewMovieImage(index: indexPath.row)
            } else {
                return self.moviesCollection.getTopRatedMovieImage(index: indexPath.row)
            }
        }
        
        cell.movieImage.kf.setImage(with: resource(), placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let initialWidth = CGFloat(180)
        let initialHeight = CGFloat(270)
        
        let itemsPerRow = CGFloat(2)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        // Calculate the change in width
        let changeInWidth = widthPerItem / initialWidth
        // Apply the change to height
        let heightPerItem = initialHeight * changeInWidth
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath)
        
        if isSearching() {
            return header
        }
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let movieHeader = header as! MovieCollectionReusableView
            
            let labelText = { () -> String in
                if indexPath.section == self.SECTION_NEW_MOVIES {
                    return "Now Showing"
                } else {
                    return "Popular"
                }
            }
            
            movieHeader.movieCollectionHeader.text = labelText()
            
            return movieHeader
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSearching() {
            movieToShow = searchedMovies[indexPath.row]
            movieImageToShow = searchedImages[indexPath.row]
        }
        else if indexPath.section == SECTION_NEW_MOVIES {
            movieToShow = moviesCollection.getNewMovie(index: indexPath.row)
            movieImageToShow = moviesCollection.getNewMovieImage(index: indexPath.row)
        } else {
            movieToShow = moviesCollection.getTopRatedMovie(index: indexPath.row)
            movieImageToShow = moviesCollection.getTopRatedMovieImage(index: indexPath.row)
        }
        
        self.pushDetailsController()
    }
    
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        // Clear search results
        clearSearch()
        
        // Ask the API to search for movies
        API.searchMovies(query: searchText, completion: { movies in
            guard let movies = movies else {
                self.displayErrorMessage("Could not find any movies")
                return
            }
            
            // Go through the movies
            for movie in movies {
                // Do not add a movie without a poster
                guard let posterPath = movie.posterPath else {
                    continue
                }
                
                // Add the movie to the list
                self.searchedMovies.append(movie)
                // Use KingFisher to get image resource and store it
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                let resource = ImageResource(downloadURL: url!, cacheKey: String(movie.id))
                self.searchedImages.append(resource)
            }
            
            self.collectionView.reloadData()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear search results
        clearSearch()
        // Reload the data
        self.collectionView.reloadData()
    }
    
    private func clearSearch() {
        // Reset the lists for storing search results
        self.searchedMovies = []
        self.searchedImages = []
    }
}

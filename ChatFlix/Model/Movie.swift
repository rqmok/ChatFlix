import Foundation

struct APIResults: Decodable {
    let page: Int
    let numResults: Int
    let numPages: Int
    let movies: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case page, numResults = "total_results", numPages = "total_pages", movies = "results"
    }
}

struct Movie: Decodable  {
    let id:Int!
    let posterPath: String?
    var videoPath: String?
    let backdrop: String?
    let title: String
    var releaseDate: String
    var rating: Double
    let overview: String
    
    private enum CodingKeys: String, CodingKey {
        case id, posterPath = "poster_path", videoPath, backdrop = "backdrop_path", title, releaseDate = "release_date", rating = "vote_average", overview
    }
}

struct VideoResults: Decodable {
    let details: [VideoKey]
    private enum CodingKeys: String, CodingKey {
        case details = "results"
    }
}

struct VideoKey: Decodable {
    let key: String
}

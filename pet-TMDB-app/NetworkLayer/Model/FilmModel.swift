//
//  FilmModel.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation

struct FilmApiResponse {
    let page: Int
    let numberOfResulst: Int
    let numberOfPages: Int
    let movies: [Film]
}

extension FilmApiResponse: Decodable {
    
    private enum MovieApiResponseCodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case movies = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieApiResponseCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfResulst = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        movies = try container.decode([Film].self, forKey: .movies)
    }
}

// в идеале Film модель отдельно для то что приходит с сервера
// и отдельно filmModel для UI 

struct Film: Hashable {
    let id: Int
    let posterPath: String
    let backdrop: String // /tmU7GeKVybMWFButWEGl2M4GeiP.jpg
    let title: String
    let releaseDate: String
    let rating: Double
    let overview: String
    
    // точно ли нужен identifier тут, если есть ID
    let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Film: Decodable {
    
    enum MovieCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case backdrop = "backdrop_path"
        case title
        case releaseDate = "release_date"
        case rating = "vote_average"
        case overview
    }
    
    
    init(from decoder: Decoder) throws {
        let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)
        
        id = try movieContainer.decode(Int.self, forKey: .id)
        posterPath = try movieContainer.decode(String.self, forKey: .posterPath)
        backdrop = try movieContainer.decode(String.self, forKey: .backdrop)
        title = try movieContainer.decode(String.self, forKey: .title)
        releaseDate = try movieContainer.decode(String.self, forKey: .releaseDate)
        rating = try movieContainer.decode(Double.self, forKey: .rating)
        overview = try movieContainer.decode(String.self, forKey: .overview)
    }
}

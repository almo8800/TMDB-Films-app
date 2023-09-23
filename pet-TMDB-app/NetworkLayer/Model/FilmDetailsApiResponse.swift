//
//  FilmDetailsApiResponse.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 23/9/23.
//

import Foundation

struct FilmDetailsApiResponse: Codable {
    let homepage: String
    let id: Int
    let popularity: Double
    let posterPath: String
    let title: String
    let overview: String
    let releaseData: String
    
    enum FilmDetailsApiCodingKeys: String, CodingKey {
        case homepage, id
        case popularity
        case posterPath = "poster_path"
        case title
        case overview
        case releaseData = "release_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FilmDetailsApiCodingKeys.self)
        homepage = try container.decode(String.self, forKey: .homepage)
        id = try container.decode(Int.self, forKey: .id)
        popularity = try container.decode(Double.self, forKey: .popularity)
        posterPath = try container.decode(String.self, forKey: .posterPath)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        releaseData = try container.decode(String.self, forKey: .releaseData)
    }
}

// MARK: - BelongsToCollection
struct BelongsToCollection: Codable {
    let id: Int
    let name, posterPath, backdropPath: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath, name, originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1, name: String
    
    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName, iso639_1, name: String
    
    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}

//
//  FilmEndPoint.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation

public enum FilmApi {

    case popular(page: Int)
    case details(id: Int)

}

extension FilmApi: EndPointType {
    
    var baseURL: URL {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    static var baseImageURL: URL {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .popular:
            return "popular"
        case .details(let id):
            return "\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .popular(let page):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["page": page,
                                                      "api_key": NetworkManager.FilmApiKey])
        case .details(_):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["" : "",
                                                      "api_key": NetworkManager.FilmApiKey])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


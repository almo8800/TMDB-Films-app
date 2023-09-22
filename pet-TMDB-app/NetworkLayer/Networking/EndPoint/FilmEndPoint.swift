//
//  FilmEndPoint.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation


//enum NetworkEnvironment {
//    case qa
//    case production
//    case staging
//}

public enum FilmApi {
    case recommended(id: Int)
    case popular(page: Int)
    case newMovies(page: Int)
    case video(id: Int)
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
        case .recommended(let id):
            return "\(id)/recommendations"
        case .popular:
            return "popular"
        case .newMovies:
            return "now_playing"
        case .video(let id):
            return "\(id)/videos"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .newMovies(let page):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["page": page,
                                                      "api_key": NetworkManager.FilmApiKey])
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


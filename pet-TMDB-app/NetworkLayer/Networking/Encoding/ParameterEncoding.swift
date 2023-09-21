//
//  ParameterEncoding.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameters encoding failed."
    case missingUrl = "URL is nil."
}

//
//  NetworkRouter.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkRouter: AnyObject { // old "class" instead AnyObject
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}



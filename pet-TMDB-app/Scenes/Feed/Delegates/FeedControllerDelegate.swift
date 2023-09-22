//
//  FeedControllerDelegate.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation

protocol FeedControllerDelegate: AnyObject {
    func feedController(_ controller: FeedViewController, didSelectFilm film: Film)
}

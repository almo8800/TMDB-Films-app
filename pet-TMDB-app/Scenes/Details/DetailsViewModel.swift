//
//  DetailsViewModel.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import RxSwift
import RxCocoa

class DetailsViewModel {
    
    var filmObservable: Observable<Void> {
        return filmDetailsPublisher.asObservable()
    }
    
    //MARK: - Properties
    
    private let networkManager: NetworkManager!
    let filmId: Int
    var filmDetails: FilmDetailsApiResponse? {
        didSet {
            if self.filmDetails != nil {
                filmDetailsPublisher.onNext(())
            }
        }
    }
    
    private let filmDetailsPublisher = PublishSubject<Void>()
    
    // MARK: - Life cycle
    
    init(networkManager: NetworkManager,
         film: Film) {
        self.networkManager = networkManager
        self.filmId = film.id
        downloadFilmDetails()
        
    }
    
    private func downloadFilmDetails() {
        networkManager.getFilmDetails(id: filmId) { details, error in
            if let error = error {
                print(error)
            }
            if let details = details {
                self.filmDetails = details
            }
        }
    }
}

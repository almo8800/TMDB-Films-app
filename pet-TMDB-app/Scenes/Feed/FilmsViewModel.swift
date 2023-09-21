//
//  FilmsViewModel.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import Foundation
import RxSwift
import RxCocoa

class FilmsViewModel {
    //MARK: - Binding properties
    var openSearch: Observable<Void> {
        return openSearchPublisher.asObservable()
    }
    
    
    //MARK: - Properties
    let networkManager: NetworkManager!
    
    private let openSearchPublisher = PublishSubject<Void>()
    
    
    
    //MARK: - Lifecycle
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    
    //MARK: - Private methods
    
    func fetchFilms() {
        networkManager.getTopRated(page: 1) { films, error in
            if let error = error {
                print(error)
            }
            if let films = films {
                self.fetchedFilms.append(contentsOf: films)
            }
        }
    }
    
    func updateSection() {
        // sections.append
    }
    
    //MARK: - Input
    func viewDidLoadTrigger() {
        //fetchFilms()
    }
    
    func searchButtonTrigger() {
        openSearchPublisher.onNext(())
    }
    
    //MARK: - Output
    private(set) var fetchedFilms: [Film] = [] {
        didSet {
            updateData()
        }
    }
    
    func updateData() {}
    
}

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
    var openFilm: Observable<Film?> {
        return openFilmPublisher.asObservable()
    }
    
    var sectionItems: Observable<[TopratedFilmsDataSet.FilmCollection]> {
        return sectionItemsPublisher.asObservable()
    }

    
    //MARK: - Properties
    let networkManager: NetworkManager
    let topRatedFilms: TopratedFilmsDataSet
    
    private(set) var collections: [TopratedFilmsDataSet.FilmCollection] = [] {
        didSet {
            sectionItemsPublisher.onNext(collections)
        }
    }
    
    private let sectionItemsPublisher = PublishSubject<[TopratedFilmsDataSet.FilmCollection]>()
    private let openFilmPublisher = BehaviorSubject<Film?>(value: nil)
    
    
    //MARK: - Lifecycle
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        topRatedFilms = .init(networkManager: networkManager)
        setupDataSetBindings()
    }
    
    
    //MARK: - Private methods
    
              
    
    //MARK: - Input
    func viewDidLoadTrigger() {
        loadContent()
    }
    
    func didSelectFilm(index: Int) {
        guard index >= 0, index < topRatedFilms.fetchedFilms.count else {
            return
        }
        
        openFilmPublisher.onNext(topRatedFilms.fetchedFilms[index])
    }
    
    func paginateFilms() {
       loadContent()
    }
    
    //MARK: - Private Methods
    
    func loadContent() {
        topRatedFilms.fetchNextPage()
    }
}

private extension FilmsViewModel {
    func setupDataSetBindings() {
        topRatedFilms.updated
            .bind(onNext: { [unowned self] _ in
               generateSections()
            })
    }
    
    func generateSections() {
        self.collections = [TopratedFilmsDataSet.FilmCollection(
            title: "Top Rated", videos: topRatedFilms.fetchedFilms)]
    }
}

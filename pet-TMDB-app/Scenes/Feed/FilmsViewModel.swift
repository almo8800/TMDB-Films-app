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
    
    var paginatedItems: Observable<[TopratedFilmsDataSet.FilmCollection]> {
        return paginatedItemsPublisher.asObservable()
    }
    
    //MARK: - Properties
    let networkManager: NetworkManager
    let popularFilms: TopratedFilmsDataSet
    
    private(set) var collections: [TopratedFilmsDataSet.FilmCollection] = [] {
        didSet {
            if oldValue.count == 0 {
                sectionItemsPublisher.onNext(collections)
            } else {
                paginatedItemsPublisher.onNext(collections)
            }
            
        }
    }
    
    private let sectionItemsPublisher = PublishSubject<[TopratedFilmsDataSet.FilmCollection]>()
    private let paginatedItemsPublisher = PublishSubject<[TopratedFilmsDataSet.FilmCollection]>()
    private let openFilmPublisher = BehaviorSubject<Film?>(value: nil)
    
    
    //MARK: - Lifecycle
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        popularFilms = .init(networkManager: networkManager)
        setupDataSetBindings()
    }
    
    //MARK: - Input
    func viewDidLoadTrigger() {
        loadContent()
    }
    
    func didSelectFilm(index: Int) {
        openFilmPublisher.onNext(popularFilms.fetchedFilms[index])
    }
    
    func paginateFilms() {
       loadContent()
    }
    
    //MARK: - Private Methods
    
    func loadContent() {
        popularFilms.fetch()
    }
}

private extension FilmsViewModel {
    private func setupDataSetBindings() {
        popularFilms.updated
            .bind(onNext: { [unowned self] _ in
               generateSections()
            })
    }
    
    private func generateSections() {
        self.collections = [TopratedFilmsDataSet.FilmCollection(
            title: "Top Rated", videos: popularFilms.fetchedFilms)]
    }
}

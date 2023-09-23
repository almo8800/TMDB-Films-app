/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Controller object that manages the videos and video collection for the sample app
*/

import Foundation
import RxSwift
import RxCocoa

class TopratedFilmsDataSet {

    struct FilmCollection: Hashable {
        let title: String
        let videos: [Film]

        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    // MARK: - Output
    
    var updated: Observable<Void> {
        return updatedPublisher.asObservable()
    }
    
    private(set) var fetchedFilms: [Film] = []
    var collections: [FilmCollection] {
        return _collections
    }
    var page = 1
    
    //MARK: - Properties

    let networkManager: NetworkManager!
    private let updatedPublisher = PublishSubject<Void>()

    
    //MARK: - Lifecycle
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    deinit {
}
    
    fileprivate var _collections = [FilmCollection]()
}

extension TopratedFilmsDataSet {
    
    func fetch() {
        networkManager.getPopularFilms(page: self.page) { films, error in
            if let error = error {
                print(error)
                self.updatedPublisher.onNext(())
            }
            if let films = films {
                self.fetchedFilms.append(contentsOf: films)
                self.updatedPublisher.onNext(())
                self.page += 1
            }
        }
    }
    
    func updateSectionCollection() {
            _collections = [FilmCollection(title: "Popular Films", videos: fetchedFilms)]
        print("Collection generated \(collections.count)")
    }
}



/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Controller object that manages the videos and video collection for the sample app
*/

import Foundation

class FilmsController {
    
    let networkManager = NetworkManager()

    struct FilmOld: Hashable {
        let title: String
        let category: String
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    struct FilmCollection: Hashable {
        let title: String
        let videos: [Film]   // было FilmOld

        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    // MARK: - Output
    var collections: [FilmCollection] {
        return _collections
    }
    
    private(set) var fetchedFilms: [Film] = [] {
        didSet {
            //updateData()
            print("$$$ Count of fetched Films \(fetchedFilms.count)")
            updateSectionCollection()
        }
    }
    
    //MARK: - Properties

    
    //MARK: - Lifecycle
    init() {
        //generateCollections()
        
       
        
    }
    fileprivate var _collections = [FilmCollection]()
}

extension FilmsController {
//    func generateCollections() {
//        _collections = [
//            FilmCollection(title: "The New iPad Pro",
//                            videos: [FilmOld(title: "Bringing Your Apps to the New iPad Pro", category: "Tech Talks"),
//                                     FilmOld(title: "Designing for iPad Pro and Apple Pencil", category: "Tech Talks")]),
//
//            FilmCollection(title: "iPhone and Apple Watch",
//                            videos: [FilmOld(title: "Building Apps for iPhone XS, iPhone XS Max, and iPhone XR",
//                                            category: "Tech Talks"),
//                                      FilmOld(title: "Designing for Apple Watch Series 4",
//                                            category: "Tech Talks"),
//                                      FilmOld(title: "Developing Complications for Apple Watch Series 4",
//                                            category: "Tech Talks"),
//                                      FilmOld(title: "What's New in Core NFC",
//                                            category: "Tech Talks")])
//        ]
//    }
    
    func fetch() {
        networkManager.getTopRated(page: 1) { films, error in
            if let error = error {
                print(error)
            }
            if let films = films {
                self.fetchedFilms.append(contentsOf: films)
            }
        }
    }
    
    func updateSectionCollection() {
            _collections = [FilmCollection(title: "Top Rated", videos: fetchedFilms)]
        print("Collection generated \(collections.count)")
    }
}
    // кажетяся сейчас коллекция генерируется раньше чем печатается все фильмы


//
//  Paginatable.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import RxSwift
import RxCocoa

final class Paginatable<T> {
    private let paginatedPublisher = PublishSubject<Void>()
    
    private let updateQueue = DispatchQueue.global()
    
    var items: [T] = []
    var page: Int = 0
    var hasMoreToLoad: Bool = false
    
    var paginated: Observable<Void> {
        return paginatedPublisher.asObservable()
    }
    
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    func reset() {
        items.removeAll(keepingCapacity: true)
        page = 0
        hasMoreToLoad = false
    }
    
    func update(withItems items: [T], page: Int, hasMoreToLoad: Bool) {
        precondition(page > 0, "Paginatable<T>::update(): page should be greater than zero")
        
        updateQueue.sync {
            self.hasMoreToLoad = hasMoreToLoad
            
            if page == 1 {
                self.items = items
                self.page = 1
            } else if page > self.page {
                self.items.append(contentsOf: items)
                self.page = page
                paginatedPublisher.onNext(())
            }
        }
    }
    
    func update() {
        paginatedPublisher.onNext(())
    }
    
    subscript(index: Int) -> T {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
}


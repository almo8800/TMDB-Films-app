//
//  Coordinator.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import UIKit

enum Event {
    case openDetails(Film)
}

protocol Coordinator {
    var navigationController: UINavigationController? {get set}
    
    func eventOccured(with type: Event)
    func start()
}

protocol Coordinating {
    var coordinator: Coordinator? { get set}
}


//
//  MainCoordinator.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController?
    
    func eventOccured(with type: Event) {
        switch type {
        case .openDetails(let film):
            let networkService = NetworkManager()
            let viewModel = DetailsViewModel(dataManager: networkService, film: film)
            let vc: UIViewController & Coordinating = DetailsViewController(viewModel: viewModel)
            navigationController?.present(vc, animated: true)
        }
    }
    
    
    
    func start() {
        let networkMGMT = NetworkManager()
        let filmsViewModel = FilmsViewModel(networkManager: networkMGMT)
        var feedViewController: UIViewController & Coordinating = FeedViewController(viewModel: filmsViewModel)
        
        feedViewController.coordinator = self
        
        
        
        navigationController?.setViewControllers([feedViewController], animated: false)
    }
    
}

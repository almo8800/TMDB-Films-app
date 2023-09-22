//
//  DetailsViewModel.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation

class DetailsViewModel {
    
    //MARK: - Properties
    let dataManager: DataManager!
    let film: Film
    
    
    // MARK: - Life cycle
    
    init(dataManager: DataManager,
         film: Film) {
        self.dataManager = dataManager
        self.film = film 
        
        setupDataSetBindings()
    }
    
    func setupDataSetBindings() {
        
    }
    
}

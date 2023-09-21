//
//  SearchController.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 20/9/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchController: UIViewController {
    
    //MARK: - UI
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        return searchBar
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
}

//
//  DetailsViewController.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class DetailsViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?
    let viewModel: DetailsViewModel
    
    //MARK: - User Interface
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        let url = URL(string: "\(FilmApi.baseImageURL)\(viewModel.film.posterPath)")
        imageView.kf.setImage(with: url)
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var releaseDataLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        return label
    }()
    
    //MARK: - LifeCycle
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        titleLabel.text = viewModel.film.title
        descriptionLabel.text = viewModel.film.overview
        releaseDataLabel.text = viewModel.film.releaseDate
        ratingLabel.text = String(viewModel.film.rating)
        
        setupUI()
    }
    
}

extension DetailsViewController {
    
    func setupUI() {
        view.addSubview(posterImageView)
        posterImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
        posterImageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        posterImageView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        posterImageView.addSubview(releaseDataLabel)
        releaseDataLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
        }
        
        posterImageView.addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalTo(releaseDataLabel.snp.trailing).offset(50)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
        }
        
        
        
    }
    
}

//
//  DetailsViewController.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher


class DetailsViewController: UIViewController, Coordinating {
    
    //MARK: - User Interface
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        return view
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
    
    //MARK: - Properties
    
    var coordinator: Coordinator?
    private let viewModel: DetailsViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - LifeCycle
    
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(" DEINIT \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        bind()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        posterImageView.addBlackGradientLayerInBackground(colors: [.black.withAlphaComponent(0.2), .clear])
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(posterImageView)
        posterImageView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
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
    
    // MARK: - Data Bindings
    
    private func configureFilmData() {
        if let posterPath = viewModel.filmDetails?.posterPath {
            let urlString = FilmApi.baseImageURL.absoluteString + posterPath
            let url = URL(string: urlString)
            
            posterImageView.kf.setImage(with: url)
            titleLabel.text = viewModel.filmDetails?.title
            descriptionLabel.text = viewModel.filmDetails?.overview
            releaseDataLabel.text = viewModel.filmDetails?.releaseData
            ratingLabel.text = String()
            if let double: Double = viewModel.filmDetails?.popularity {
                ratingLabel.text = String(double)
            }
        }
    }
    
    private func bind() {
        viewModel.filmObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                self.configureFilmData()
            }).disposed(by: disposeBag)
    }
}




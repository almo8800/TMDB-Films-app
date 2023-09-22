

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class FeedViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?
    
    let viewModel: FilmsViewModel
    
    // MARK: - UI Setup
    
    private lazy var navigationTitleView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "playstation.logo")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var searchBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "magnifyingglass.circle.fill"), style: .plain, target: nil, action: nil)
        item.tintColor = .black
        item.rx.tap
            .bind { [unowned self] (_) in
        }.disposed(by: disposeBag)
        
        return item
    }()

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    var networkManager: NetworkManager!
    var collectionView: UICollectionView!
  
    var delegate: FeedControllerDelegate?
    
    var dataSource: UICollectionViewDiffableDataSource
        <TopratedFilmsDataSet.FilmCollection, Film>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
        <TopratedFilmsDataSet.FilmCollection, Film>! = nil
    
    
    static let titleElementKind = "title-element-kind"

    // MARK: - Overriden methods
    
    init(viewModel: FilmsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationItem.title = "TEST"
        
        viewModel.viewDidLoadTrigger()
        
        setupUI()
        bind()
        configureHierarchy()
        configureDataSource()
        updateSnapshot()
        
        
    }
    
    // MARK: - UI Setuo
    func setupUI() {
        setupNavBarItems()
}
    
    private func setupNavBarItems() {
        
        let image = UIImage(systemName: "pencil.circle")
        let button = UIButton(type: .custom)
        button.tintColor = .black
        button.setImage(image, for: .normal)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    func bind() {
        viewModel.sectionItems
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] (items) in
                
                configureHierarchy()
                configureDataSource()
                updateSnapshot()

                
                collectionView.delegate = self
                
            }.disposed(by: disposeBag)
        
        viewModel.openFilm
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] film in
                guard let film = film else { return }
                coordinator?.eventOccured(with: .openDetails(film))
            }).disposed(by: disposeBag)
            }
    }


extension FeedViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
                0.425 : 0.85)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                                  heightDimension: .absolute(250))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: FeedViewController.titleElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

extension FeedViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .gray
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration
        <FilmCell, Film> { (cell, IndexPath, video) in
            // Populate the cell with our item description.
            
            cell.titleLabel.text = video.title
            cell.categoryLabel.text = video.overview
            
            let url = URL(string: "\(FilmApi.baseImageURL)\(video.backdrop)")
            cell.imageView.kf.setImage(with: url)
            
            cell.contentView.isUserInteractionEnabled = false
            // поставить placeHolder в KingFisher (или в ячейке картинку по дефолту)
        }
        
        dataSource = UICollectionViewDiffableDataSource
        
        
       
        <TopratedFilmsDataSet.FilmCollection, Film>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, video: Film) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: video)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: FeedViewController.titleElementKind) {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.currentSnapshot {
                // Populate the view with our section's description.
                let videoCategory = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = videoCategory.title
            }
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
//        currentSnapshot = NSDiffableDataSourceSnapshot
//        <TopratedFilmsDataSet.FilmCollection, Film>()
//
//            viewModel.collections.forEach {
//                let collection = $0
//                currentSnapshot.appendSections([collection])
//                currentSnapshot.appendItems(collection.videos)
//            }
//            dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    func updateSnapshot() {
    currentSnapshot = NSDiffableDataSourceSnapshot
    <TopratedFilmsDataSet.FilmCollection, Film>()
    
        viewModel.collections.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.videos)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }

}

extension FeedViewController: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filmIndex = indexPath[1]
        viewModel.didSelectFilm(index: filmIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.topRatedFilms.fetchedFilms.count-2 {
            // fetchedFilms отдавать вo ViewModel сразу?
            viewModel.paginateFilms()
            
        }
    }
    
}

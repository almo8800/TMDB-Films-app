

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class FeedViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?
    private let viewModel: FilmsViewModel
    
    // MARK: - User Interface
    
    private lazy var searchBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle"), style: .plain, target: nil, action: nil)
        item.tintColor = .black
        item.rx.tap
            .bind { [unowned self] (_) in
               showAlert()
        }.disposed(by: disposeBag)
        
        return item
    }()
    
    private var collectionView: UICollectionView!

    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var networkManager: NetworkManager!
    private var delegate: FeedControllerDelegate?
    
    private var dataSource: UICollectionViewDiffableDataSource
        <TopratedFilmsDataSet.FilmCollection, Film>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot
        <TopratedFilmsDataSet.FilmCollection, Film>! = nil
    
    static let titleElementKind = "title-element-kind"
    private var lastContentOffset: CGPoint = .zero

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
        navigationItem.title = "TMDB"
        view.backgroundColor = .white
        
        viewModel.viewDidLoadTrigger()
        setupUI()
        bind()
    }
    
    // MARK: - UI Setuo
    private func setupUI() {
        setupNavBarItems()
}
    
    private func setupNavBarItems() {
        navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    //MARK: - Binding
    
    private func bind() {
        viewModel.sectionItems
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] (items) in
                
                configureHierarchy()
                configureDataSource()
        
                collectionView.delegate = self
                
            }.disposed(by: disposeBag)
        
        viewModel.paginatedItems
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] _ in
                updateSnapshot()
            }
        
        viewModel.openFilm
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] film in
                guard let film = film else { return }
                coordinator?.eventOccured(with: .openDetails(film))
            }).disposed(by: disposeBag)
            }
    }

//MARK: - Compositional Collection Layout

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
        collectionView.backgroundColor = .lightGray
        
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
            cell.descriptionLabel.text = video.overview
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
        
        currentSnapshot = NSDiffableDataSourceSnapshot
        <TopratedFilmsDataSet.FilmCollection, Film>()
        
            viewModel.collections.forEach {
                let collection = $0
                currentSnapshot.appendSections([collection])
                currentSnapshot.appendItems(collection.videos)
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    func updateSnapshot() {
        currentSnapshot = NSDiffableDataSourceSnapshot
        <TopratedFilmsDataSet.FilmCollection, Film>()
        
        viewModel.collections.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.videos)
        }

        dataSource.applySnapshotUsingReloadData(currentSnapshot, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate

extension FeedViewController: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filmIndex = indexPath.row
        viewModel.didSelectFilm(index: filmIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.popularFilms.fetchedFilms.count-2 {
            // fetchedFilms отдавать вo ViewModel сразу?
            lastContentOffset = collectionView.contentOffset
            viewModel.paginateFilms()
            lastContentOffset = collectionView.contentOffset
        }
    }
}

//MARK: - Alert

extension FeedViewController {
    private func showAlert() {
        let alertController = UIAlertController(title: "Search is not ready", message: "Waiting for next version", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            print("OK button tapped")
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}

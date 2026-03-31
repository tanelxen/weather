//
//  ViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class WeatherViewController: UIViewController {
    
    private let headerView = HeaderView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private let loaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    private let errorView = ErrorView()
    
    private let presenter: WeatherPresenter = WeatherPresenterImpl()
    private var viewModel: WeatherViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        layout()
        configure()
    }
    
    private func layout() {
        view.addSubview(loaderView)
        loaderView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
        }
    }
    
    private func configure() {
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "GlobalHeaderKind", withReuseIdentifier: "GlobalHeader")
        collectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.identifier)
        collectionView.register(DailyCell.self, forCellWithReuseIdentifier: DailyCell.identifier)
        collectionView.dataSource = self
        
        presenter.view = self
        
        collectionView.isHidden = true
        errorView.isHidden = true
        
        errorView.onRetry = { [weak self] in
            self?.presenter.loadData()
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        presenter.loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WeatherViewController: WeatherView {
    func update(with state: WeatherViewState) {
        switch state {
            case .loading: showLoading()
            case .success(let vm): showSuccess(vm)
            case .error(let message): showError(message)
        }
    }
    
    private func showSuccess(_ vm: WeatherViewModel) {
        
        self.viewModel = vm
        headerView.configure(with: vm.header)
        collectionView.reloadData()
        collectionView.isHidden = false
        
        loaderView.stopAnimating()
        errorView.isHidden = false
    }
    
    private func showLoading() {
        loaderView.startAnimating()
        collectionView.isHidden = true
        errorView.isHidden = true
    }
    
    private func showError(_ message: String) {
        loaderView.stopAnimating()
        collectionView.isHidden = true
        
        errorView.message = message
        errorView.isHidden = false
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { SectionType.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let viewModel else { return 0 }
        
        switch SectionType(rawValue: section) {
            case .hourly: return viewModel.hourly.count
            case .daily: return viewModel.daily.count
            case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let viewModel else { return UICollectionViewCell() }
        
        switch SectionType(rawValue: indexPath.section) {
            case .hourly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.identifier, for: indexPath) as! HourlyCell
                let hour = viewModel.hourly[indexPath.item]
                cell.configure(with: hour)
                return cell
                
            case .daily:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCell.identifier, for: indexPath) as! DailyCell
                let day = viewModel.daily[indexPath.item]
                cell.configure(with: day)
                return cell
                
            case .none: return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "GlobalHeaderKind" {
            let headerContainer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GlobalHeader", for: indexPath)
            
            headerContainer.addSubview(headerView)
            headerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            return headerContainer
        }
            
        return UICollectionReusableView()
    }
}

private enum SectionType: Int, CaseIterable {
    case hourly = 0
    case daily = 1
}

private func createLayout() -> UICollectionViewLayout {
    
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
        switch SectionType(rawValue: sectionIndex) {
            case .hourly: return makeHourlySection(environment: environment)
            case .daily: return makeDailySection()
            case .none: return nil
        }
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.boundarySupplementaryItems = [
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)),
            elementKind: "GlobalHeaderKind",
            alignment: .top
        )
    ]
    layout.configuration = config
    
    layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SectionBackgroundView.reuseIdentifier)
    return layout
}

private func makeHourlySection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let containerWidth = environment.container.effectiveContentSize.width
    let itemWidth = containerWidth  / 5
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(116))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(116))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.orthogonalScrollingBehavior = .groupPaging
    //    section.interGroupSpacing = 4
    
    let background = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundView.reuseIdentifier)
    background.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.decorationItems = [background]
    
    return section
}

private func makeDailySection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.interGroupSpacing = 4
    
    let background = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundView.reuseIdentifier)
    background.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.decorationItems = [background]
    
    return section
}

private final class SectionBackgroundView: UICollectionReusableView {
    static let reuseIdentifier = "SectionBackgroundViewReuseIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class WeatherViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "sky")
        return view
    }()
    
    private let skyViewController = SkyViewController()
    
    private let currentView = CurrentView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private let loaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    private let errorView = ErrorView()
    
    private let presenter: WeatherPresenter
    private(set) var viewModel: WeatherViewModel?
    
    init(presenter: WeatherPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        
        layout()
        configure()
    }
    
    private func layout() {
        
        addChild(skyViewController)
        view.addSubview(skyViewController.view)
        skyViewController.view.snp.makeConstraints({ $0.edges.equalToSuperview() })
        skyViewController.didMove(toParent: self)
        
        view.addSubview(loaderView)
        loaderView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(currentView)
        currentView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(currentView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        collectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.identifier)
        collectionView.register(DailyCell.self, forCellWithReuseIdentifier: DailyCell.identifier)
        collectionView.dataSource = self
        
        presenter.view = self
        
        collectionView.isHidden = true
        errorView.isHidden = true
        
        errorView.onRetry = { [weak self] in
            self?.presenter.loadData()
        }
        
        // Обновляем данные при возврате в foreground
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
            case .error(let vm): showAlert(vm)
        }
    }
    
    private func showSuccess(_ vm: WeatherViewModel) {
        
        self.viewModel = vm
        currentView.configure(with: vm.current)
        collectionView.reloadData()
        
        currentView.isHidden = false
        collectionView.isHidden = false
        
        loaderView.stopAnimating()
        errorView.isHidden = true
    }
    
    private func showLoading() {
        loaderView.startAnimating()
        currentView.isHidden = true
        collectionView.isHidden = true
        errorView.isHidden = true
    }
    
    private func showAlert(_ vm: AlertViewModel) {
        loaderView.stopAnimating()
        
        currentView.isHidden = true
        collectionView.isHidden = true
        
        errorView.configure(with: vm)
        errorView.isHidden = false
    }
}

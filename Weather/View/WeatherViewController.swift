//
//  ViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class WeatherViewController: UIViewController {
    
    let headerView = HeaderView()
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
            case .error(let vm): showAlert(vm)
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
    
    private func showAlert(_ vm: AlertViewModel) {
        loaderView.stopAnimating()
        collectionView.isHidden = true
        
        errorView.configure(with: vm)
        errorView.isHidden = false
    }
}

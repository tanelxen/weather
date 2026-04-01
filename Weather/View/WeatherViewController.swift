//
//  ViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class WeatherViewController: UIViewController {
    
    private var skyView: SkyViewProtocol!
    private let currentView = CurrentView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .white
        return refreshControl
    }()
    
    private let loaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.color = .white
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
        
        layout()
        configure()
    }
    
    private func layout() {
        
        let skyViewController = SkyViewController()
        addChild(skyViewController)
        view.addSubview(skyViewController.view)
        skyViewController.view.snp.makeConstraints({ $0.edges.equalToSuperview() })
        skyViewController.didMove(toParent: self)
        skyView = skyViewController
        
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
            $0.top.equalTo(currentView.snp.bottom).offset(-64)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        collectionView.contentInset.top = 64
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        collectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.identifier)
        collectionView.register(DailyCell.self, forCellWithReuseIdentifier: DailyCell.identifier)
        collectionView.refreshControl = refreshControl
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
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(showSettings))
        tap.minimumPressDuration = 1.0
        currentView.addGestureRecognizer(tap)
        currentView.isUserInteractionEnabled = true
    }
    
    @objc private func appDidBecomeActive() {
        presenter.loadData()
    }
    
    @objc private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.presenter.loadData()
        }
    }
    
    @objc private func showSettings() {
        let vc = SkySettingsViewController(delegate: skyView)
        
        if let sheet = vc.sheetPresentationController {
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WeatherViewController: WeatherView {
    func update(with state: WeatherViewState) {
        switch state {
            case .loading:
                if refreshControl.isRefreshing { break }
                showLoading()
            case .success(let vm): showSuccess(vm)
            case .error(let vm): showAlert(vm)
        }
        
        refreshControl.endRefreshing()
    }
    
    private func showSuccess(_ vm: WeatherViewModel) {
        
        skyView?.sunHeight = vm.current.isDay ? 1 : 0
        skyView?.cloudiness = vm.current.cloudiness
        
        viewModel = vm
        currentView.configure(with: vm.current)
        collectionView.reloadData()
        
        currentView.isHidden = false
        collectionView.isHidden = false
        
        currentView.alpha = 0
        collectionView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.currentView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.collectionView.alpha = 1
        }
        
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

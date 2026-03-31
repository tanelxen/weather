//
//  ErrorView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import UIKit
import SnapKit

final class ErrorView: UIView
{
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "exclamationmark.triangle")
        view.heightAnchor.constraint(equalToConstant: 64).isActive = true
        view.widthAnchor.constraint(equalToConstant: 64).isActive = true
        view.tintColor = .systemPink
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.title = "Повторить"
        button.configuration = config
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        layout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: AlertViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        
        retryButton.isHidden = !viewModel.isRetriable
    }
    
    private func layout() {
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel, retryButton])
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 16
        
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.setCustomSpacing(36, after: messageLabel)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    private func configure() {
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 24
        
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
    }
    
    @objc func handleRetry() {
        
        // Throttle
        retryButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.retryButton.isEnabled = true
        }
        
        onRetry?()
    }
}

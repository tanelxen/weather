//
//  HourlyCell.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//


import UIKit
import SnapKit

final class HourlyCell: UICollectionViewCell {
    
    static let identifier = "HourlyCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.text = "01"
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.text = " 0°"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        contentView.addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configure(with model: WeatherViewModel.HourlyItem) {
        timeLabel.text = model.time
        tempLabel.text = model.temp
        imageView.loadImage(from: model.iconUrl)
    }
}

extension UIImageView {
    func loadImage(from urlString: String) {
        let fullPath = "https:\(urlString)" // API отдает путь без схемы
        guard let url = URL(string: fullPath) else { return }
        
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
}

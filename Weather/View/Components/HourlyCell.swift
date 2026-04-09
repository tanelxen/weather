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
        label.textColor = .white
        label.text = "-"
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
        label.font = .monospacedSystemFont(ofSize: 18, weight: .light)
        label.textColor = .white
        label.text = "-"
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
            $0.centerX.equalToSuperview().offset(4)
        }
    }
    
    func configure(with model: ForecastWeatherViewModel.HourlyItem) {
        timeLabel.text = model.time
        tempLabel.text = model.temp
        imageView.loadImage(from: model.iconUrl)
    }
}

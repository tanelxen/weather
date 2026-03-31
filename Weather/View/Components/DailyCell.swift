//
//  DailyCell.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import UIKit
import SnapKit

final class DailyCell: UICollectionViewCell {
    
    static let identifier = "DailyCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
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
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .right
        label.textColor = .label
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
        
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(100)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        contentView.addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with model: WeatherViewModel.DailyItem) {
        dayLabel.text = model.day
        tempLabel.text = model.temp
        imageView.loadImage(from: model.iconUrl)
    }
}

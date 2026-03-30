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
        label.text = "Сегодня"
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
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        label.textColor = .label
        label.text = "0°"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        contentView.addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
        }
    }
    
//    func configure(with forecast: ForecastDay) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        if let date = formatter.date(from: forecast.date) {
//            formatter.dateFormat = "EEEE" // "Monday"
//            dayLabel.text = formatter.string(from: date).capitalized
//        }
//        
//        tempLabel.text = "\(Int(forecast.day.avgtemp_c))°"
//        iconView.loadImage(from: forecast.day.condition.icon)
//    }
}

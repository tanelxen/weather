//
//  SummaryView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class HeaderView: UIView {
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .regular)
        label.textColor = .label
        label.text = "-"
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .light)
        label.textColor = .label
        label.text = "-°"
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "-"
        return label
    }()
    
    private let rangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        addSubview(cityLabel)
        cityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(cityLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview().offset(8)
        }
        
        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(rangeLabel)
        rangeLabel.snp.makeConstraints {
            $0.top.equalTo(conditionLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configure(with model: WeatherViewModel.Header) {
        
        cityLabel.text = model.city
        tempLabel.text = model.temp
        conditionLabel.text = model.condition
        rangeLabel.text = model.range
    }
}

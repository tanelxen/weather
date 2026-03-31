//
//  SummaryView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import UIKit
import SnapKit

final class HeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "HeaderView"

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
        label.text = "Макс: 10°, мин: 20°"
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
        
        let stackView = UIStackView(arrangedSubviews: [cityLabel, tempLabel, conditionLabel, rangeLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        stackView.setCustomSpacing(4, after: conditionLabel)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with model: WeatherViewModel.Header) {
        
        cityLabel.text = model.city
        tempLabel.text = model.temp
        conditionLabel.text = model.condition
    }
}

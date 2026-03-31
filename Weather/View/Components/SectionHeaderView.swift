//
//  SectionHeaderView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import UIKit
import SnapKit

final class SectionHeaderView: UICollectionReusableView
{
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.5)
        label.text = "-"
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.5)
        return view
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title?.uppercased()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

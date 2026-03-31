//
//  WeatherViewController+Layout.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import UIKit

extension WeatherViewController {
    
    static func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            switch SectionType(rawValue: sectionIndex) {
                case .hourly: return makeHourlySection(environment: environment)
                case .daily: return makeDailySection()
                case .none: return nil
            }
        }
        
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SectionBackgroundView.reuseIdentifier)
        return layout
    }
}

private func makeHourlySection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let containerWidth = environment.container.effectiveContentSize.width
    let itemWidth = containerWidth  / 5
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(116))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(116))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.orthogonalScrollingBehavior = .groupPaging
    
    let background = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundView.reuseIdentifier)
    background.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.decorationItems = [background]
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52)),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top)
//    header.pinToVisibleBounds = true
    section.boundarySupplementaryItems = [header]
    
    return section
}

private func makeDailySection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
    
    let background = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundView.reuseIdentifier)
    background.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.decorationItems = [background]
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52)),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top)
//    header.pinToVisibleBounds = true
    section.boundarySupplementaryItems = [header]
    
    return section
}

private final class SectionBackgroundView: UICollectionReusableView {
    static let reuseIdentifier = "SectionBackgroundViewReuseIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

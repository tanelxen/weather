//
//  File.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import UIKit
import SnapKit

extension WeatherViewController: UICollectionViewDataSource {
    
    enum SectionType: Int, CaseIterable {
        case hourly = 0
        case daily = 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { SectionType.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let viewModel else { return 0 }
        
        switch SectionType(rawValue: section) {
            case .hourly: return viewModel.hourly.count
            case .daily: return viewModel.daily.count
            case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let viewModel else { return UICollectionViewCell() }
        
        switch SectionType(rawValue: indexPath.section) {
            case .hourly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.identifier, for: indexPath) as! HourlyCell
                let hour = viewModel.hourly[indexPath.item]
                cell.configure(with: hour)
                return cell
                
            case .daily:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCell.identifier, for: indexPath) as! DailyCell
                let day = viewModel.daily[indexPath.item]
                cell.configure(with: day)
                return cell
                
            case .none: return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "GlobalHeaderKind" {
            let headerContainer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GlobalHeader", for: indexPath)
            
            headerContainer.addSubview(headerView)
            headerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            return headerContainer
        }
        
        return UICollectionReusableView()
    }
}

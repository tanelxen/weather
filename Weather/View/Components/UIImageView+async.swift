//
//  UIImageView+async.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

import UIKit

extension UIImageView {
    
    static let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String) {
        self.image = nil
        
        if let cachedImage = Self.cache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url), let image = UIImage(data: data) {
                
                await MainActor.run {
                    Self.cache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
        }
    }
}

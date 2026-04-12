//
//  CustomAnimator.swift
//  Weather
//
//  Created by Fedor Artemenkov on 12.04.26.
//

import QuartzCore

final class CustomAnimator {
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    private var duration: TimeInterval = 0
//    private var startValue: CGFloat = 0
//    private var endValue: CGFloat = 0
    private var updateHandler: ((Float) -> Void)?
    private var completionHandler: (() -> Void)?
    
    func animate(duration: TimeInterval,
                 update: @escaping (_ progress: Float) -> Void,
                 completion: (() -> Void)? = nil) {
        
        self.duration = duration
        self.updateHandler = update
        self.completionHandler = completion
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateTick))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }
    
    @objc private func updateTick() {
        guard let startTime = startTime else { return }
        
        let elapsedTime = CACurrentMediaTime() - startTime
        let progress = min(1.0, elapsedTime / duration)
        updateHandler?(Float(progress))
        
        if progress >= 1.0 {
            stop()
            completionHandler?()
        }
    }
    
    private func stop() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
    }
    
//    private func easeInOut(_ t: CGFloat) -> CGFloat {
//        return t < 0.5  ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
//    }
}

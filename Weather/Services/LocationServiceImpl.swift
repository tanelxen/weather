//
//  LocationServiceImpl.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//


import CoreLocation

final class LocationServiceImpl: NSObject {
    
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?
    
    private let defaultLocation = CLLocation(latitude: 55.752, longitude: 37.616)

    override init() {
        super.init()
        
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = kCLLocationAccuracyKilometer
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        manager.delegate = self
    }
    
    private func resume(with location: CLLocation) {
        manager.stopUpdatingLocation()
        continuation?.resume(returning: location)
        continuation = nil
    }
}

extension LocationServiceImpl: LocationService {
    
    func getCurrentLocation() async -> CLLocation {
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            
            let status = manager.authorizationStatus
            switch status {
                case .notDetermined:
                    manager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    resume(with: defaultLocation)
                case .authorizedWhenInUse, .authorizedAlways:
                    manager.startUpdatingLocation()
                @unknown default:
                    resume(with: defaultLocation)
            }
        }
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            resume(with: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resume(with: defaultLocation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if (status == .authorizedWhenInUse || status == .authorizedAlways) && continuation != nil {
            manager.startUpdatingLocation()
        } else if status == .denied {
            resume(with: defaultLocation)
        }
    }
}

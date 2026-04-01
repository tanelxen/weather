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
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        manager.delegate = self
    }
}

extension LocationServiceImpl: LocationService {
    
    func getCurrentLocation() async -> CLLocation {
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            
            let status = manager.authorizationStatus
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else if status == .denied || status == .restricted {
                continuation.resume(returning: defaultLocation)
                self.continuation = nil
            } else {
                manager.startUpdatingLocation()
            }
        }
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            continuation?.resume(returning: location)
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        continuation?.resume(returning: defaultLocation)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else if manager.authorizationStatus == .denied {
            continuation?.resume(returning: defaultLocation)
            continuation = nil
        }
    }
}

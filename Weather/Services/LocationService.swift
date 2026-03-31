//
//  LocationService.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import CoreLocation

protocol LocationService: AnyObject {
    func getCurrentLocation() async -> CLLocation
}

final class LocationServiceMock: LocationService {
    
    private let moscowLocation = CLLocation(latitude: 55.752, longitude: 37.616)
    
    func getCurrentLocation() async -> CLLocation {
        return moscowLocation
    }
}

//final class LocationServiceImpl: LocationService {
//    
//    private let moscowLocation = CLLocation(latitude: 55.752, longitude: 37.616)
//    
//    func getCurrentLocation() async -> CLLocation {
//        
//        do {
//            let userLocation = try await CLLocationUpdate.requestLocation()
//            print("User location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
//        } catch {
//            print("Failed to fetch location: \(error.localizedDescription)")
//        }
//    }
//}



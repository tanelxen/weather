//
//  LocationService.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import CoreLocation

/*
 
 
 func fetchCurrentLocation() async throws -> CLLocation {
 let location = try await CLLocationUpdate.self.requestLocation()
 return location
 }
 
 Task {
 do {
 let userLocation = try await fetchCurrentLocation()
 print("User location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
 } catch {
 print("Failed to fetch location: \(error.localizedDescription)")
 }
 }
 */

final class LocationService {
    
    private let moscowLocation = CLLocation(latitude: 55.752, longitude: 37.616)
    
    func getCurrentLocation() async -> CLLocation {
        return moscowLocation
    }
}

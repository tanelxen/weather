//
//  NetworkService.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    
    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = URL(string: "https://api.weatherapi.com/v1")!
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private init() {}
    
    func getCurrent(latitude: Double, longitude: Double) async -> CurrentResponse? {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("current.json"),
            resolvingAgainstBaseURL: false
        )
        
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(latitude), \(longitude)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return await doRequest(request, decodeTo: CurrentResponse.self)
    }
    
    func getForecast(latitude: Double, longitude: Double, days: Int) async -> ForecastResponse? {
        
        var components = URLComponents(
            url: baseURL.appendingPathComponent("forecast.json"),
            resolvingAgainstBaseURL: false
        )
        
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(latitude), \(longitude)"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "days", value: String(days)),
            URLQueryItem(name: "lang", value: "ru")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return await doRequest(request, decodeTo: ForecastResponse.self)
    }
    
    private func doRequest<T: Decodable>(_ request: URLRequest, decodeTo type: T.Type) async -> T? {

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let stringResponse = String(data: data, encoding: .utf8) ?? ""
            print("Response: \(stringResponse)")
            
            return try decoder.decode(type.self, from: data)
            
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}

struct CurrentResponse: Decodable {
    let location: WeatherAPI.Location
    let current: WeatherAPI.Current
}


struct ForecastResponse: Decodable {
    let location: WeatherAPI.Location
    let current: WeatherAPI.Current
    let forecast: WeatherAPI.Forecast
}



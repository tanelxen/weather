//
//  WeatherClientImpl.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import Foundation

final class WeatherClientImpl: WeatherClient {
    
    private let apiKey: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.weatherapi.com/v1")!
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        
        self.session = URLSession(configuration: config)
    }
    
    func getForecast(latitude: Double, longitude: Double, days: Int) async throws -> ForecastResponse {
        let params = ["q": "\(latitude),\(longitude)", "days": "\(days)"]
        return try await get("forecast.json", params: params)
    }
    
    private func get<T: Decodable>(_ endpoint: String, params: [String: String]) async throws -> T {
        
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: false
        )!
        
        var queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "lang", value: "ru"))
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw WeatherError.apiError(errorResponse.error.code, errorResponse.error.message)
            }
            throw WeatherError.apiError(httpResponse.statusCode, "Unknown error")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

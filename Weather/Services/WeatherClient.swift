//
//  NetworkService.swift
//  Weather
//
//  Created by Fedor Artemenkov on 30.03.26.
//

import Foundation

protocol WeatherClient {
    func getForecast(latitude: Double, longitude: Double, days: Int) async throws -> ForecastResponse
}

struct ForecastResponse: Decodable {
    let location: WeatherAPI.Location
    let current: WeatherAPI.Current
    let forecast: WeatherAPI.Forecast
}

struct ErrorResponse: Decodable {
    let error: WeatherAPI.Error
}

enum WeatherError: Error, LocalizedError {
    case apiError(Int, String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
            case .apiError(let code, let message):
                return "WeatherAPI error \(code): \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
        }
    }
}

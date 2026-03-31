//
//  WeatherView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//


@MainActor
protocol WeatherView: AnyObject {
    func update(with: WeatherViewState)
}

enum WeatherViewState {
    case loading
    case success(WeatherViewModel)
    case error(message: String)
}

struct WeatherViewModel {
    let header: Header
    let hourly: [HourlyItem]
    let daily: [DailyItem]
    
    struct Header {
        let city: String
        let temp: String
        let condition: String
        let range: String
    }
    
    struct HourlyItem {
        let time: String
        let temp: String
        let iconUrl: String
    }
    
    struct DailyItem {
        let day: String
        let temp: String
        let iconUrl: String
    }
}

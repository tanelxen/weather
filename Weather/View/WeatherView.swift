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
    case error(AlertViewModel)
}

struct WeatherViewModel {
    let current: Current
    let hourly: Hourly
    let daily: Daily
    
    struct Current {
        let city: String
        let temp: String
        let condition: String
    }
    
    struct Hourly {
        let header: String
        let items: [HourlyItem]
    }
    
    struct HourlyItem {
        let time: String
        let temp: String
        let iconUrl: String
    }
    
    struct Daily {
        let header: String
        let items: [DailyItem]
    }
    
    struct DailyItem {
        let day: String
        let temp: String
        let iconUrl: String
    }
}

struct AlertViewModel {
    let title: String
    let message: String
    let isRetriable: Bool
}

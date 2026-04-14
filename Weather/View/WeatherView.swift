//
//  WeatherView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//


@MainActor
protocol WeatherView: AnyObject {
    func render(_ state: WeatherViewState)
}

enum WeatherViewState {
    case initialLoading
    case refreshing
    case success(CurrentWeatherViewModel, ForecastWeatherViewModel)
    case error(AlertViewModel)
}

struct CurrentWeatherViewModel {
    let city: String
    let temp: String
    let condition: String
    let dayTime: Int
    let shaderParams: WeatherShaderParams
}

struct ForecastWeatherViewModel {
    let hourly: Hourly
    let daily: Daily
    
    struct Hourly {
        let header: String
        let items: [HourlyItem]
    }
    
    struct HourlyItem {
        var time: String
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

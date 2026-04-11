//
//  WeatherView.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//


@MainActor
protocol WeatherView: AnyObject {
    func update(with: CurrentWeatherViewModel)
    func update(with: ForecastWeatherViewModel)
    
    func showAlert(_ viewModel: AlertViewModel)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
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

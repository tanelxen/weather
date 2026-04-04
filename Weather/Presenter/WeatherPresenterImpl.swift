//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import Foundation

final class WeatherPresenterImpl: WeatherPresenter {
    
    weak var view: WeatherView?
    
    private let weatherClient: WeatherClient
    private let locationService: LocationService
    
    init(weatherClient: WeatherClient, locationService: LocationService) {
        self.weatherClient = weatherClient
        self.locationService = locationService
    }
    
    func loadData() {
        Task {
            await view?.update(with: .loading)
            await loadWeather()
        }
    }
    
    func refresh() {
        Task {
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        
        let coords = await locationService.getCurrentLocation().coordinate
        
        do {
            let data = try await weatherClient.getForecast(latitude: coords.latitude, longitude: coords.longitude, days: 3)
            
            let vm = makeViewModel(from: data)
            await view?.update(with: .success(vm))
            
        } catch {
            
            if let weatherError = error as? WeatherError, case .apiError(let code, _) = weatherError {
                let message = (code == 2006) ? "Удостоверьтесь, что у вас валидный API-ключ" : error.localizedDescription
                let vm = AlertViewModel(title: "Что-то пошло не так", message: message, isRetriable: false)
                await view?.update(with: .error(vm))
                return
            }
            
            let vm = AlertViewModel(title: "Что-то пошло не так", message: error.localizedDescription, isRetriable: true)
            await view?.update(with: .error(vm))
        }
    }
}

private func makeViewModel(from data: ForecastResponse) -> WeatherViewModel {
    
    let current = WeatherViewModel.Current(
        city: data.location.name,
        temp: String(format: "%.0f°", data.current.temp_c),
        condition: data.current.condition.text,
        isDay: data.current.is_day == 1,
        shaderParams: WeatherShaderParams.make(from: data.current.condition.code)
    )
    
    let showCurrentHour = true
    let capTo24Hours = true
    
    let now = Int(Date().timeIntervalSince1970) - (showCurrentHour ? 3599 : 0)
    let hours = data.forecast.forecastday.prefix(2).flatMap(\.hour)
    
    var filtered = hours.filter { $0.time_epoch > now }
    if capTo24Hours {
        filtered = Array(filtered.prefix(24))
    }
    
    var hourlyItems: [WeatherViewModel.HourlyItem] = filtered.map { .init(from: $0) }
    
    if showCurrentHour, !hourlyItems.isEmpty {
        hourlyItems[0].time = "Сейчас"
    }
    
    let dailyItems: [WeatherViewModel.DailyItem] = data.forecast.forecastday.map { .init(from: $0) }
    let dailyTitle = "Прогноз на " + pluralizeDays(dailyItems.count)
    
    return WeatherViewModel(
        current: current,
        hourly: .init(header: "Почасовой прогноз", items: hourlyItems),
        daily: .init(header: dailyTitle, items: dailyItems)
    )
}

private func pluralizeDays(_ count: Int) -> String {
    let remainder10 = count % 10
    let remainder100 = count % 100
    
    if remainder10 == 1 && remainder100 != 11 {
        return "\(count) день"
    } else if (remainder10 >= 2 && remainder10 <= 4) && (remainder100 < 10 || remainder100 >= 20) {
        return "\(count) дня"
    } else {
        return "\(count) дней"
    }
}

private func unixToHour(unixTime: TimeInterval, timeZone: TimeZone = .current) -> String {
    let date = Date(timeIntervalSince1970: unixTime)
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = "HH"
    
    return dateFormatter.string(from: date)
}

private extension WeatherViewModel.HourlyItem {
    init(from model: WeatherAPI.Hour) {
        self.time = unixToHour(unixTime: TimeInterval(model.time_epoch))
        self.temp = String(format: "%.0f°", Double(model.temp_c))
        self.iconUrl = "https:" + model.condition.icon
    }
}

private extension WeatherViewModel.DailyItem
{
    init(from model: WeatherAPI.ForecastDay)
    {
        let date = Date(timeIntervalSince1970: TimeInterval(model.date_epoch))
        let isDateInToday = Calendar.current.isDateInToday(date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.dateFormat = "EEE"
        
        self.day = isDateInToday ? "Сегодня" : dateFormatter.string(from: date)
        
        self.temp = String(format: "%3.0f°  | %3.0f°", model.day.mintemp_c, model.day.maxtemp_c)
        
        self.iconUrl = "https:" + model.day.condition.icon
    }
}

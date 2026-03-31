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
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        
        await view?.update(with: .loading)
        
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
    
    let current = data.current
    
    var range: String = ""
    
    // Backend присылает странные данные, current.temp_c может оказаться выше today.day.maxtemp_c
//    if let today = data.forecast.forecastday.first {
//        range = String(format: "мин: %.0f°, макс: %.0f°", today.day.mintemp_c, today.day.maxtemp_c)
//    }
    
    let header = WeatherViewModel.Header(
        city: data.location.name,
        temp: String(format: "%.0f°", current.temp_c),
        condition: current.condition.text,
        range: range
    )
    
    let now = Int(Date().timeIntervalSince1970)
    let hours = data.forecast.forecastday.prefix(2).flatMap(\.hour)
    let filtered = hours.filter { $0.time_epoch > now }//.prefix(24)
    let hourly: [WeatherViewModel.HourlyItem] = filtered.map { .init(from: $0) }
    
    let daily: [WeatherViewModel.DailyItem] = data.forecast.forecastday.map { .init(from: $0) }
    
    return WeatherViewModel(
        header: header,
        hourly: hourly,
        daily: daily
    )
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
        self.iconUrl = model.condition.icon
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
        
        self.temp = String(format: "мин: %.0f°, макс: %.0f°", model.day.mintemp_c, model.day.maxtemp_c)
        
        self.iconUrl = model.day.condition.icon
    }
}

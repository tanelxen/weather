//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import Foundation
import CoreLocation

final class WeatherPresenterImpl: WeatherPresenter {
    
    weak var view: WeatherView?
    
    private let weatherClient: WeatherClient
    private let locationService: LocationService
    
    private var lastLocation: CLLocation?
    
    init(weatherClient: WeatherClient, locationService: LocationService) {
        self.weatherClient = weatherClient
        self.locationService = locationService
    }
    
    func loadData() {
        Task {
            await view?.showLoadingIndicator()
            
            let location = await locationService.getCurrentLocation()
            await loadForecast(with: location.coordinate)
            
            lastLocation = location
        }
    }
    
    func refresh() {
        Task {
            let location = await locationService.getCurrentLocation()
            
            if let lastLocation, lastLocation.distance(from: location) < 1000 {
                await loadCurrent(with: location.coordinate)
            } else {
                await loadForecast(with: location.coordinate)
            }
            
            lastLocation = location
        }
    }
    
    private func loadCurrent(with coords: CLLocationCoordinate2D) async {
        
        do {
            let data = try await weatherClient.getCurrent(latitude: coords.latitude, longitude: coords.longitude)
            
            await view?.hideLoadingIndicator()
            
            let current = makeViewModel(from: data.current, location: data.location)
            await view?.update(with: current)
            
        } catch {
            await processError(error)
        }
    }
    
    private func loadForecast(with coords: CLLocationCoordinate2D) async {
        
        do {
            let data = try await weatherClient.getForecast(latitude: coords.latitude, longitude: coords.longitude, days: 3)
            
            await view?.hideLoadingIndicator()
            
            let current = makeViewModel(from: data.current, location: data.location)
            await view?.update(with: current)
            
            let forecast = makeViewModel(from: data.forecast, location: data.location)
            await view?.update(with: forecast)
            
        } catch {
            await processError(error)
        }
    }
    
    private func processError(_ error: Error) async {
        
        await view?.hideLoadingIndicator()
        
        let apiKeyCodes: Set<Int> = [1002, 2006, 2007, 2008]
        
        if let weatherError = error as? WeatherError, case .apiError(let code, _) = weatherError, apiKeyCodes.contains(code) {
            let message = "Удостоверьтесь, что у вас валидный API-ключ"
            let vm = AlertViewModel(title: "Что-то пошло не так", message: message, isRetriable: false)
            await view?.showAlert(vm)
            return
        }
        
        let vm = AlertViewModel(title: "Что-то пошло не так", message: error.localizedDescription, isRetriable: true)
        await view?.showAlert(vm)
    }
}

private func makeViewModel(from current: WeatherAPI.Current, location: WeatherAPI.Location) -> CurrentWeatherViewModel {
    
    return CurrentWeatherViewModel(
        city: location.name,
        temp: String(format: "%.0f°", current.temp_c),
        condition: current.condition.text,
        isDay: current.is_day == 1,
        shaderParams: WeatherShaderParams.make(from: current.condition.code)
    )
}

private func makeViewModel(from forecast: WeatherAPI.Forecast, location: WeatherAPI.Location) -> ForecastWeatherViewModel {
    
    let showCurrentHour = true
    let capTo24Hours = true
    
    let now = Int(location.localtime_epoch) - (showCurrentHour ? 3599 : 0)
    let hours = forecast.forecastday.prefix(2).flatMap(\.hour)
    
    var filtered = hours.filter { $0.time_epoch > now }
    if capTo24Hours {
        filtered = Array(filtered.prefix(24))
    }
    
    let timeZone = TimeZone(identifier: location.tz_id)!
    
    var hourlyItems: [ForecastWeatherViewModel.HourlyItem] = filtered.map { .init(from: $0, timeZone: timeZone) }
    
    if showCurrentHour, !hourlyItems.isEmpty {
        hourlyItems[0].time = "Сейчас"
    }
    
    let offset = timeZone.secondsFromGMT()
    let localGMT = Date(timeIntervalSince1970: TimeInterval(location.localtime_epoch + offset))
    
    let dailyItems: [ForecastWeatherViewModel.DailyItem] = forecast.forecastday.map { .init(from: $0, localGMT: localGMT) }
    let dailyTitle = "Прогноз на " + pluralizeDays(dailyItems.count)
    
    return ForecastWeatherViewModel(
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

private extension ForecastWeatherViewModel.HourlyItem {
    
    init(from model: WeatherAPI.Hour, timeZone: TimeZone) {
        let timeInterval = TimeInterval(model.time_epoch)
        self.time = unixToHour(unixTime: timeInterval, timeZone: timeZone)
        self.temp = String(format: "%.0f°", Double(model.temp_c))
        self.iconUrl = "https:" + model.condition.icon
    }
}

private extension ForecastWeatherViewModel.DailyItem {
    
    init(from model: WeatherAPI.ForecastDay, localGMT: Date) {
        let date = Date(timeIntervalSince1970: TimeInterval(model.date_epoch))
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "EEE"
        
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let isToday = utcCalendar.isDate(date, inSameDayAs: localGMT)
        
        self.day = isToday ? "Сегодня" : dateFormatter.string(from: date)
        
        self.temp = String(format: "%3.0f°  | %3.0f°", model.day.mintemp_c, model.day.maxtemp_c)
        
        self.iconUrl = "https:" + model.day.condition.icon
    }
}

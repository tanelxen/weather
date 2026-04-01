//
//  WeatherAPI.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//

import Foundation

enum WeatherAPI {
    
    struct Location: Decodable {
        let name: String
        let region: String
        let lat: Double
        let lon: Double
        let localtime_epoch: Int
    }
    
    struct Current: Decodable {
        let last_updated_epoch: Int
        let temp_c: Double
        let condition: Condition
        let is_day: Int
        let cloud: Int
    }
    
    struct Condition: Decodable {
        let text: String
        let icon: String
        let code: Int
    }

    struct Forecast: Decodable {
        let forecastday: [ForecastDay]
    }
    
    struct ForecastDay: Decodable {
        let date_epoch: Int
        let day: Day
        let hour: [Hour]
    }
    
    struct Day: Decodable {
        let maxtemp_c: Double
        let avgtemp_c: Double
        let mintemp_c: Double
        let condition: Condition
    }
    
    struct Hour: Decodable {
        let time_epoch: Int
        let temp_c: Double
        let condition: Condition
    }
}

extension WeatherAPI {
    struct Error: Decodable {
        let code: Int
        let message: String
    }
}

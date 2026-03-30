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
        let temp_c: Double
        let condition: Condition
        let is_day: Int
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
        let date: String
        let day: Day
        let hour: [Hour]
    }
    
    struct Day: Decodable {
        let avgtemp_c: Double
        let condition: Condition
    }
    
    struct Hour: Decodable {
        let time_epoch: Int
        let temp_c: Double
        let condition: Condition
    }
}

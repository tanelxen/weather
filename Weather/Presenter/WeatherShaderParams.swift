//
//  WeatherShaderParams.swift
//  Weather
//
//  Created by Fedor Artemenkov on 04.04.26.
//


import Foundation

struct WeatherShaderParams {
    let cloud: Float
    let rain: Float
    let snow: Float
    let fog: Float
    
    init(cloud: Float = 0, rain: Float = 0, snow: Float = 0, fog: Float = 0) {
        self.cloud = cloud
        self.rain = rain
        self.snow = snow
        self.fog = fog
    }
}

extension WeatherShaderParams {
    static func make(from code: Int) -> WeatherShaderParams {
        return mapCodeToParams(code)
    }
}

private func mapCodeToParams(_ code: Int) -> WeatherShaderParams {
    switch code {
        case 1000: // Sunny / Clear
            return WeatherShaderParams(cloud: 0.0)
            
        case 1003: // Partly cloudy
            return WeatherShaderParams(cloud: 0.3)
            
        case 1006, 1009: // Cloudy, Overcast
            return WeatherShaderParams(cloud: 0.8)
            
        case 1030, 1135, 1147: // Mist, Fog, Freezing fog
            return WeatherShaderParams(cloud: 0.6, fog: 0.9)
            
            // ДОЖДЬ
        case 1063, 1180, 1183, 1240: // Light rain / Patchy rain
            return WeatherShaderParams(cloud: 0.7, rain: 0.4)
            
        case 1186, 1189, 1243: // Moderate rain
            return WeatherShaderParams(cloud: 0.9, rain: 0.7)
            
        case 1192, 1195, 1246: // Heavy rain / Torrential
            return WeatherShaderParams(cloud: 1.0, rain: 1.0)
            
            // СНЕГ
        case 1066, 1210, 1213, 1255: // Light snow
            return WeatherShaderParams(cloud: 0.7, snow: 0.4)
            
        case 1216, 1219, 1258: // Moderate snow
            return WeatherShaderParams(cloud: 0.9, snow: 0.7)
            
        case 1114, 1117, 1222, 1225: // Blizzard / Heavy snow
            return WeatherShaderParams(cloud: 1.0, snow: 1.0, fog: 0.5)
            
            // ГРОЗА
        case 1087, 1273, 1276, 1279, 1282:
            return WeatherShaderParams(cloud: 1.0, rain: 0.8)
            
            // СМЕШАННЫЕ (Слякоть / Град)
        case 1069, 1072, 1168, 1171, 1198, 1201, 1204, 1207, 1237, 1249, 1252, 1261, 1264:
            return WeatherShaderParams(cloud: 0.9, rain: 0.5, snow: 0.5)
            
        default:
            return WeatherShaderParams()
    }
}

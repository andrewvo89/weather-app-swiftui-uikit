
//
//  Weather.swift
//  weather-app-ios-swift
//
//  Created by Lucas Hahn on 11/5/21.
//
import Foundation
import GooglePlaces

struct WeatherData: Decodable {
    let current: CurrentWeather
    let daily: [ForecastWeather]
}

struct CurrentWeather: Decodable {
    let temp: Double
    let dt: Int //date
    let feels_like: Double
    let pressure: Double
    let humidity: Double
    let wind_speed: Double
    let sunrise: Int
    let sunset: Int
    let weather: [Weather]
}

struct ForecastWeather: Decodable {
    let temp: ForecastTemp
    let dt: Int //date
    let weather: [Weather]
}

struct ForecastTemp: Decodable {
    let min: Double
    let max: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

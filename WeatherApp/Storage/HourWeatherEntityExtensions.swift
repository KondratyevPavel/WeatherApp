//
//  HourWeatherEntityExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


extension HourWeatherEntity {

  convenience init(context: NSManagedObjectContext, model: HourWeather, location: WeatherLocationEntity) {
    self.init(context: context)

    self.timestamp = Int64(model.timestamp)
    self.location = location
    update(with: model)
  }

  func makeModel() -> HourWeather? {
    guard let weatherType = WeatherType(rawValue: Int(weatherTypeRaw)) else { return nil }

    return HourWeather(
      timestamp: Int(timestamp),
      temperatureC: temperatureC,
      weatherType: weatherType
    )
  }

  func update(with model: HourWeather) {
    temperatureC = model.temperatureC
    weatherTypeRaw = Int32(model.weatherType.rawValue)
  }
}

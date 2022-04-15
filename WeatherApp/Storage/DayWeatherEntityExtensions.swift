//
//  DayWeatherEntityExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


extension DayWeatherEntity {

  convenience init(context: NSManagedObjectContext, model: DayWeather, location: WeatherLocationEntity) {
    self.init(context: context)

    self.timestamp = Int64(model.timestamp)
    self.location = location
    update(with: model)
  }

  func makeModel() -> DayWeather? {
    guard let weatherType = WeatherType(rawValue: Int(weatherTypeRaw)) else { return nil }

    return DayWeather(
      timestamp: Int(timestamp),
      minTemperatureC: minTemperatureC,
      maxTemperatureC: maxTemperatureC,
      weatherType: weatherType
    )
  }

  func update(with model: DayWeather) {
    minTemperatureC = model.minTemperatureC
    maxTemperatureC = model.maxTemperatureC
    weatherTypeRaw = Int32(model.weatherType.rawValue)
  }
}

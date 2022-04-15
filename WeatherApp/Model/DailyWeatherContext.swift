//
//  DailyWeatherContext.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


struct DailyWeatherContext: Hashable {

  var location: WeatherLocation
  var timezone: TimeZone
}

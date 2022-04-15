//
//  HourlyWeatherContext.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


struct HourlyWeatherContext: Hashable {

  var location: WeatherLocation
  var timezone: TimeZone
  var initialTimestamp: Int
}

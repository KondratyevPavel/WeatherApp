//
//  WeatherDataContext.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


struct WeatherDataContext: Hashable {

  var location: WeatherLocation
  var timezone: TimeZone
}

//
//  WeatherTypeExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


extension WeatherType {

  var icon: UIImage {
    let iconName: String
    switch self {
    case .clear:
      iconName = "sun.max"
    case .semiCloudy:
      iconName = "cloud.sun"
    case .cloudy:
      iconName = "cloud"
    case .fog:
      iconName = "cloud.fog"
    case .drizzle:
      iconName = "cloud.drizzle"
    case .lightRain:
      iconName = "cloud.sun.rain"
    case .rain:
      iconName = "cloud.rain"
    case .heavyRain:
      iconName = "cloud.heavyrain"
    case .snow:
      iconName = "cloud.snow"
    case .rainBolt:
      iconName = "cloud.bolt.rain"
    case .hail:
      iconName = "cloud.hail"
    }
    return UIImage(systemName: iconName)!
  }
}

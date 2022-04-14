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
    case .cloudy:
      iconName = "cloud"
    case .rain:
      iconName = "cloud.rain"
    }
    return UIImage(systemName: iconName)!
  }
}

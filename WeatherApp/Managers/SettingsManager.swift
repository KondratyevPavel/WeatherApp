//
//  SettingsManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import Foundation


protocol SettingsManagerProtocol {

  var weatherLocation: WeatherLocation { get }

  func setWeatherLocation(_ location: WeatherLocation)
}


class SettingsManager: SettingsManagerProtocol {

  private let defaults: UserDefaults = .standard

  init() {
    defaults.register(defaults: [
      .weatherLocationLatitude: 52.5235,
      .weatherLocationLongitude: 13.4115
    ])
  }

  // MARK: - SettingsManagerProtocol

  var weatherLocation: WeatherLocation {
    return WeatherLocation(
      latitude: defaults.double(forKey: .weatherLocationLatitude),
      longitude: defaults.double(forKey: .weatherLocationLongitude)
    )
  }

  func setWeatherLocation(_ location: WeatherLocation) {
    defaults.set(location.latitude, forKey: .weatherLocationLatitude)
    defaults.set(location.longitude, forKey: .weatherLocationLongitude)
  }
}

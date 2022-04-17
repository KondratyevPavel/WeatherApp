//
//  UserDefaultsExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import Foundation


extension UserDefaults {

  func double(forKey key: UserDefaultsKey) -> Double {
    return double(forKey: key.rawValue)
  }

  func set(_ value: Double, forKey key: UserDefaultsKey) {
    set(value, forKey: key.rawValue)
  }

  func register(defaults: [UserDefaultsKey: Any]) {
    register(defaults: Dictionary(defaults.map { ($0.key.rawValue, $0.value) }, uniquingKeysWith: { $1 }))
  }
}

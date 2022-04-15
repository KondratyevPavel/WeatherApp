//
//  DataConstants.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


enum DataConstants {

  static let daysPerWeek = 7
  static let hoursPerDay = 24
  static let minutesPerHour = 60
  static let secondsPerMinute = 60
  static let secondsPerHour = secondsPerMinute * minutesPerHour
  static let secondsPerDay = secondsPerHour * hoursPerDay
  static let hoursPerWeek = hoursPerDay * daysPerWeek
}

//
//  DateFormatterFactory.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 16.04.22.
//

import Foundation


enum DateFormatterFactory {

  static func makeTime(timezone: TimeZone) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.dateFormat = "HH:mm"
    return formatter
  }

  static func makeDate(timezone: TimeZone) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.dateFormat = "EEEE, dd"
    return formatter
  }

  static func makeWeekday(timezone: TimeZone) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.dateFormat = "EEE"
    return formatter
  }

  static func makeServerDate(timezone: TimeZone) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }

  static func makeServerDateTime(timezone: TimeZone) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return formatter
  }
}

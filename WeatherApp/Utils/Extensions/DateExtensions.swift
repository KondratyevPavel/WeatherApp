//
//  DateExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


extension Date {

  func sameDate(as date: Date, in timezone: TimeZone) -> Bool {
    var calendar = Calendar.current
    calendar.timeZone = timezone
    let selfComponents = calendar.dateComponents([.year, .month, .day], from: self)
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    return selfComponents == dateComponents
  }

  func getMidnight(in timezone: TimeZone) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = timezone
    let components = calendar.dateComponents([.year, .month, .day], from: self)
    return calendar.date(from: components)!
  }
}

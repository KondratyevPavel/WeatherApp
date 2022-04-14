//
//  FixedWidthIntegerExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


extension FixedWidthInteger {

  init<T: BinaryFloatingPoint>(clamping value: T) {
    if value <= T(.min) {
      self = .min
    } else if value >= T(.max) {
      self = .max
    } else {
      self.init(value)
    }
  }

  init<T: BinaryFloatingPoint>(clamping value: T, rule: FloatingPointRoundingRule) {
    self.init(clamping: value.rounded(rule))
  }
}

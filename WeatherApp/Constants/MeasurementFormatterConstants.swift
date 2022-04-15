//
//  MeasurementFormatterConstants.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


enum MeasurementFormatterConstants {

  static let temperature: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    numberFormatter.allowsFloats = false
    formatter.numberFormatter = numberFormatter
    return formatter
  }()
}

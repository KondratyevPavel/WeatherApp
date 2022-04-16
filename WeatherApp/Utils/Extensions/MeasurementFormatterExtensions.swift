//
//  MeasurementFormatterExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 16.04.22.
//

import Foundation


extension MeasurementFormatter {

  func string(temperatureC: Double) -> String {
    let temperatureMeasurement: Measurement<Unit> = Measurement(
      value: temperatureC,
      unit: UnitTemperature.celsius
    )
    let result = string(from: temperatureMeasurement)
    return result
  }
}

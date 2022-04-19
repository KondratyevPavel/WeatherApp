//
//  UIFontConstants.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import UIKit


enum UIFontConstants {

  static let main: UIFont = .systemFont(ofSize: FontSizeConstants.main)
  static let largeDayTemperature: UIFont = .systemFont(ofSize: FontSizeConstants.hugeMain)
  static let largeDayDate: UIFont = .systemFont(ofSize: FontSizeConstants.hugeDetail)
  static let smallDayTemperature: UIFont = .systemFont(ofSize: FontSizeConstants.main)
  static let smallDayDate: UIFont = .systemFont(ofSize: FontSizeConstants.detail)
  static let hourTime: UIFont = .monospacedSystemFont(ofSize: FontSizeConstants.main, weight: .medium)
  static let hourTemperature: UIFont = .systemFont(ofSize: FontSizeConstants.main)
}

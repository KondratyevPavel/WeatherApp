//
//  DayWeatherView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import UIKit


protocol DayWeatherView {

  var iconView: UIImageView { get }
  var maxTemperatureLabel: UILabel { get }
  var minTemperatureLabel: UILabel { get }
}


extension DayWeatherView {

  func setup(with dayWeather: DayWeather?) {
    if let dayWeather = dayWeather {
      iconView.image = dayWeather.weatherType.icon
      let maxTemperatureMeasurement: Measurement<Unit> = Measurement(
        value: dayWeather.maxTemperatureC,
        unit: UnitTemperature.celsius
      )
      maxTemperatureLabel.text = MeasurementFormatterConstants.temperature.string(from: maxTemperatureMeasurement)
      let minTemperatureMeasurement: Measurement<Unit> = Measurement(
        value: dayWeather.minTemperatureC,
        unit: UnitTemperature.celsius
      )
      minTemperatureLabel.text = MeasurementFormatterConstants.temperature.string(from: minTemperatureMeasurement)
    } else {
      iconView.image = UIImage(systemName: "questionmark")!
      maxTemperatureLabel.text = "--"
      minTemperatureLabel.text = "--"
    }
  }
}

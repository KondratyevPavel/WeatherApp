//
//  DayWeatherView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import UIKit


protocol DayWeatherView {

  var dateLabel: UILabel { get }
  var iconView: UIImageView { get }
  var minTemperatureLabel: UILabel { get }
  var maxTemperatureLabel: UILabel { get }
}


extension DayWeatherView {

  func setup(with dayWeather: DayWeather?, timestamp: Int, dateFormatter: DateFormatter) {
    dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    if let dayWeather = dayWeather {
      iconView.image = dayWeather.weatherType.icon
      let formatter = MeasurementFormatterConstants.temperature
      minTemperatureLabel.text = formatter.string(temperatureC: dayWeather.minTemperatureC)
      maxTemperatureLabel.text = formatter.string(temperatureC: dayWeather.maxTemperatureC)
    } else {
      iconView.image = UIImage(systemName: "questionmark")!
      minTemperatureLabel.text = "--"
      maxTemperatureLabel.text = "--"
    }
  }
}

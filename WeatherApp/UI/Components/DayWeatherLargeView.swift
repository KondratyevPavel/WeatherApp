//
//  DayWeatherLargeView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class DayWeatherLargeView: UIView {

  let dateLabel = UILabel()
  let iconView = UIImageView()
  let temperatureLabel = UILabel()

  init() {
    super.init(frame: .zero)

    dateLabel.font = UIFontConstants.largeDayDate

    temperatureLabel.font = UIFontConstants.largeDayTemperature

    LayoutFactory.makeLabelIconLabelVertical(
      in: self,
      topLabel: dateLabel,
      iconView: iconView,
      bottomLabel: temperatureLabel
    )
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup(with dayWeather: DayWeather?, timestamp: Int, dateFormatter: DateFormatter) {
    dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    if let dayWeather = dayWeather {
      iconView.image = dayWeather.weatherType.icon
      let formatter = MeasurementFormatterConstants.temperature
      let minTemperature = formatter.string(temperatureC: dayWeather.minTemperatureC)
      let maxTemperature = formatter.string(temperatureC: dayWeather.maxTemperatureC)
      temperatureLabel.text = "\(minTemperature)/\(maxTemperature)"
    } else {
      iconView.image = UIImage(systemName: "questionmark")!
      temperatureLabel.text = "--/--"
    }
  }
}

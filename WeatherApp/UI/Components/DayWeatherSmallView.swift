//
//  DayWeatherSmallView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class DayWeatherSmallView: UIView {

  private static let minWidthForSingleLineTemperature = calculateMinWidthForSingleLineTemperature()

  private var dayWeather: DayWeather?
  
  let dateLabel = UILabel()
  let iconView = UIImageView()
  let temperatureLabel = UILabel()

  init() {
    super.init(frame: .zero)

    dateLabel.font = UIFontConstants.smallDayDate
    
    temperatureLabel.font = UIFontConstants.smallDayTemperature
    temperatureLabel.numberOfLines = 2

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
    self.dayWeather = dayWeather

    dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    if let dayWeather = dayWeather {
      iconView.image = dayWeather.weatherType.icon
    } else {
      iconView.image = UIImage(systemName: "questionmark")!
    }
    refreshTemperatureLabel()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    refreshTemperatureLabel()
  }
}


// MARK: - Private
private extension DayWeatherSmallView {

  func refreshTemperatureLabel() {
    let minTemperature: String
    let maxTemperature: String
    if let dayWeather = dayWeather {
      let formatter = MeasurementFormatterConstants.temperature
      minTemperature = formatter.string(temperatureC: dayWeather.minTemperatureC)
      maxTemperature = formatter.string(temperatureC: dayWeather.maxTemperatureC)
    } else {
      minTemperature = "--"
      maxTemperature = "--"
    }
    if layoutMarginsGuide.layoutFrame.width >= DayWeatherSmallView.minWidthForSingleLineTemperature {
      temperatureLabel.text = "\(minTemperature)/\(maxTemperature)"
    } else {
      temperatureLabel.text = "\(minTemperature)\n\(maxTemperature)"
    }
  }

  static func calculateMinWidthForSingleLineTemperature() -> CGFloat {
    var widestChar = "0"
    var widestCharWidth = widestChar.size(font: UIFontConstants.smallDayTemperature).width
    for index in 1...9 {
      let char = "\(index)"
      let charWidth = char.size(font: UIFontConstants.smallDayTemperature).width
      if charWidth > widestCharWidth {
        widestCharWidth = charWidth
        widestChar = char
      }
    }
    return "-\(widestChar)\(widestChar)°/-\(widestChar)\(widestChar)°"
      .size(font: UIFontConstants.smallDayTemperature).width
  }
}

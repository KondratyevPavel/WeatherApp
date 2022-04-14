//
//  DayWeatherSmallView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class DayWeatherSmallView: UIView {

  private let iconView = UIImageView()
  private let maxTemperatureLabel = UILabel()
  private let minTemperatureLabel = UILabel()

  init() {
    super.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false

    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(iconView)

    maxTemperatureLabel.textAlignment = .right
    maxTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    maxTemperatureLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    maxTemperatureLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
    addSubview(maxTemperatureLabel)

    minTemperatureLabel.textAlignment = .right
    minTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(minTemperatureLabel)

    let iconLeadingConstraint = iconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
    iconLeadingConstraint.priority = .medium

    NSLayoutConstraint.activate([
      iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
      iconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      iconView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      iconView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
      iconLeadingConstraint,

      maxTemperatureLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor),
      maxTemperatureLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      maxTemperatureLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),

      minTemperatureLabel.topAnchor.constraint(equalTo: maxTemperatureLabel.bottomAnchor),
      minTemperatureLabel.leadingAnchor.constraint(equalTo: maxTemperatureLabel.leadingAnchor),
      minTemperatureLabel.widthAnchor.constraint(equalTo: maxTemperatureLabel.widthAnchor),
      minTemperatureLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])

    setup(with: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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

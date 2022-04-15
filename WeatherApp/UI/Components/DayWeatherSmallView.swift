//
//  DayWeatherSmallView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class DayWeatherSmallView: UIView, DayWeatherView {

  let iconView = UIImageView()
  let maxTemperatureLabel = UILabel()
  let minTemperatureLabel = UILabel()

  init() {
    super.init(frame: .zero)

    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(iconView)

    minTemperatureLabel.font = UIFontConstants.smallDayWeatherLabel
    minTemperatureLabel.textAlignment = .right
    minTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    minTemperatureLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    minTemperatureLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
    addSubview(minTemperatureLabel)

    maxTemperatureLabel.font = UIFontConstants.smallDayWeatherLabel
    maxTemperatureLabel.textAlignment = .right
    maxTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    maxTemperatureLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    maxTemperatureLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
    addSubview(maxTemperatureLabel)

    let iconLeadingConstraint = iconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
    iconLeadingConstraint.priority = .medium

    NSLayoutConstraint.activate([
      iconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      iconView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      iconView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
      iconLeadingConstraint,

      minTemperatureLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor),
      minTemperatureLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      minTemperatureLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),

      maxTemperatureLabel.topAnchor.constraint(equalTo: minTemperatureLabel.bottomAnchor),
      maxTemperatureLabel.leadingAnchor.constraint(equalTo: minTemperatureLabel.leadingAnchor),
      maxTemperatureLabel.widthAnchor.constraint(equalTo: minTemperatureLabel.widthAnchor),
      maxTemperatureLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])

    setup(with: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

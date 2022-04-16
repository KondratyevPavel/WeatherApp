//
//  DayWeatherLargeView.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class DayWeatherLargeView: UIView, DayWeatherView {

  let dateLabel = UILabel()
  let iconView = UIImageView()
  let minTemperatureLabel = UILabel()
  let maxTemperatureLabel = UILabel()

  init() {
    super.init(frame: .zero)

    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .vertical)
    iconView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    addSubview(iconView)

    minTemperatureLabel.font = UIFontConstants.largeDayTemperature
    minTemperatureLabel.textAlignment = .center
    minTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(minTemperatureLabel)

    maxTemperatureLabel.font = UIFontConstants.largeDayTemperature
    maxTemperatureLabel.textAlignment = .center
    maxTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(maxTemperatureLabel)
    
    dateLabel.font = UIFontConstants.largeDayDate
    dateLabel.textAlignment = .center
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(dateLabel)

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
      maxTemperatureLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      maxTemperatureLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),

      dateLabel.topAnchor.constraint(equalTo: maxTemperatureLabel.bottomAnchor),
      dateLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
      dateLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

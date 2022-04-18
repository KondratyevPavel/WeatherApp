//
//  LayoutFactory.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 18.04.22.
//

import UIKit


enum LayoutFactory {

  static func makeLabelIconLabelVertical(
    in view: UIView,
    topLabel: UILabel,
    iconView: UIImageView,
    bottomLabel: UILabel
  ) {
    topLabel.textAlignment = .center
    topLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(topLabel)

    let dateIconSpacing = UILayoutGuide()
    view.addLayoutGuide(dateIconSpacing)

    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .vertical)
    iconView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    iconView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
    iconView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    view.addSubview(iconView)

    let iconTemperatureSpacing = UILayoutGuide()
    view.addLayoutGuide(iconTemperatureSpacing)

    bottomLabel.textAlignment = .center
    bottomLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bottomLabel)

    let iconWidthConstraint = iconView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor)
    iconWidthConstraint.priority = .medium

    NSLayoutConstraint.activate([
      topLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      topLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      topLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),

      dateIconSpacing.topAnchor.constraint(equalTo: topLabel.bottomAnchor),
      dateIconSpacing.bottomAnchor.constraint(equalTo: iconView.topAnchor),

      iconView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
      iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
      iconWidthConstraint,

      iconTemperatureSpacing.topAnchor.constraint(equalTo: iconView.bottomAnchor),
      iconTemperatureSpacing.bottomAnchor.constraint(equalTo: bottomLabel.topAnchor),
      iconTemperatureSpacing.heightAnchor.constraint(equalTo: dateIconSpacing.heightAnchor),

      bottomLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      bottomLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
      bottomLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
    ])
  }
}

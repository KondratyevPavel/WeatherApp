//
//  WeatherOverviewViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


protocol WeatherOverviewViewControllerDelegateListener {

  func dailyWeatherChanged()
}


protocol WeatherOverviewViewControllerDelegate: Listenable {

  var dailyWeather: [DayWeather?] { get }

  func refetchDataIfNeeded()
}


class WeatherOverviewViewController: UIViewController, WeatherOverviewViewControllerDelegateListener {

  private static let smallDayViewsCount = DataConstants.weatherDaysCount - 1

  private let model: WeatherOverviewViewControllerDelegate
  private var smallDayViews: [DayWeatherSmallView] = []

  init(model: WeatherOverviewViewControllerDelegate) {
    self.model = model

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.backgroundColor = .systemBackground

    let bottomPanel = createBottomPanel()
    view.addSubview(bottomPanel)
    NSLayoutConstraint.activate([
      bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      bottomPanel.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: LayoutConstants.bottomPanelHeight)
    ])

    dailyWeatherChanged()
    model.addListener(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    model.refetchDataIfNeeded()
  }

  // MARK: - WeatherOverviewViewControllerDelegateListener

  func dailyWeatherChanged() {
    for (dayView, dayWeather) in zip(smallDayViews, model.dailyWeather.dropFirst()) {
      dayView.setup(with: dayWeather)
    }
  }
}


// MARK: - Private
private extension WeatherOverviewViewController {

  /// must only be called once
  func createBottomPanel() -> UIView {
    let bottomPanel = UIStackView()
    bottomPanel.translatesAutoresizingMaskIntoConstraints = false
    bottomPanel.isLayoutMarginsRelativeArrangement = true
    bottomPanel.preservesSuperviewLayoutMargins = true

    smallDayViews.reserveCapacity(WeatherOverviewViewController.smallDayViewsCount)
    for index in 0..<WeatherOverviewViewController.smallDayViewsCount {
      if index > 0 {
        let separator = ViewFactory.makeVerticalSeparator()
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(separator)
        NSLayoutConstraint.activate([
          wrapper.leadingAnchor.constraint(equalTo: separator.leadingAnchor),
          wrapper.trailingAnchor.constraint(equalTo: separator.trailingAnchor),
          wrapper.layoutMarginsGuide.topAnchor.constraint(equalTo: separator.topAnchor),
          wrapper.layoutMarginsGuide.bottomAnchor.constraint(equalTo: separator.bottomAnchor)
        ])
        bottomPanel.addArrangedSubview(wrapper)
      }
      let dayView = DayWeatherSmallView()
      smallDayViews.append(dayView)
      bottomPanel.addArrangedSubview(dayView)
      if index > 0 {
        dayView.widthAnchor.constraint(equalTo: smallDayViews[index - 1].widthAnchor).isActive = true
      }
    }

    return bottomPanel
  }
}


// MARK: - LayoutConstants
private extension LayoutConstants {

  static let bottomPanelHeight: CGFloat = 100
}

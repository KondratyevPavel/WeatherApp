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
  func openDay(index: Int)
}


class WeatherOverviewViewController: UIViewController, WeatherOverviewViewControllerDelegateListener {

  private static let smallDayViewsCount = DataConstants.daysPerWeek - 1

  private let model: WeatherOverviewViewControllerDelegate
  private lazy var largeDayView: DayWeatherLargeView = createLargeDayView()
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
    bottomPanel.translatesAutoresizingMaskIntoConstraints = false
    bottomPanel.preservesSuperviewLayoutMargins = true
    view.addSubview(bottomPanel)

    let largeDayButton = UIButton()
    largeDayButton.addTarget(self, action: #selector(largeDayPressed), for: .touchUpInside)
    largeDayButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(largeDayButton)

    largeDayView.translatesAutoresizingMaskIntoConstraints = false
    largeDayView.isUserInteractionEnabled = false
    largeDayButton.addSubview(largeDayView)

    NSLayoutConstraint.activate([
      bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      bottomPanel.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: LayoutConstants.bottomPanelHeight),

      largeDayButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      largeDayButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      largeDayButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      largeDayButton.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),

      largeDayView.topAnchor.constraint(equalTo: largeDayButton.topAnchor),
      largeDayView.bottomAnchor.constraint(equalTo: largeDayButton.bottomAnchor),
      largeDayView.leadingAnchor.constraint(equalTo: largeDayButton.leadingAnchor),
      largeDayView.trailingAnchor.constraint(equalTo: largeDayButton.trailingAnchor)
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
    largeDayView.setup(with: model.dailyWeather.first ?? nil)
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
    bottomPanel.isLayoutMarginsRelativeArrangement = true

    smallDayViews.reserveCapacity(WeatherOverviewViewController.smallDayViewsCount)
    for index in 0..<WeatherOverviewViewController.smallDayViewsCount {
      if index > 0 {
        let separator = createWrappedSeparator()
        separator.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.addArrangedSubview(separator)
      }
      let dayView = DayWeatherSmallView()
      let dayButton = createSmallDayButton(index: index, view: dayView)
      dayButton.translatesAutoresizingMaskIntoConstraints = false
      smallDayViews.append(dayView)
      bottomPanel.addArrangedSubview(dayButton)
      if index > 0 {
        dayView.widthAnchor.constraint(equalTo: smallDayViews[index - 1].widthAnchor).isActive = true
      }
    }

    return bottomPanel
  }

  func createWrappedSeparator() -> UIView {
    let separator = ViewFactory.makeVerticalSeparator()
    let wrapper = UIView()
    separator.translatesAutoresizingMaskIntoConstraints = false
    wrapper.addSubview(separator)
    NSLayoutConstraint.activate([
      wrapper.leadingAnchor.constraint(equalTo: separator.leadingAnchor),
      wrapper.trailingAnchor.constraint(equalTo: separator.trailingAnchor),
      wrapper.layoutMarginsGuide.topAnchor.constraint(equalTo: separator.topAnchor),
      wrapper.layoutMarginsGuide.bottomAnchor.constraint(equalTo: separator.bottomAnchor)
    ])
    return wrapper
  }

  func createSmallDayButton(index: Int, view: DayWeatherSmallView) -> UIButton {
    let dayButton = UIButton()
    dayButton.tag = index + 1
    dayButton.addTarget(self, action: #selector(smallDayPressed(_:)), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    dayButton.addSubview(view)

    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: dayButton.topAnchor),
      view.bottomAnchor.constraint(equalTo: dayButton.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: dayButton.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: dayButton.trailingAnchor)
    ])

    return dayButton
  }

  func createLargeDayView() -> DayWeatherLargeView {
    let largeDayView = DayWeatherLargeView()
    return largeDayView
  }

  @objc
  func largeDayPressed() {
    model.openDay(index: 0)
  }

  @objc
  func smallDayPressed(_ sender: UIButton) {
    model.openDay(index: sender.tag)
  }
}


// MARK: - LayoutConstants
private extension LayoutConstants {

  static let bottomPanelHeight: CGFloat = 100
}

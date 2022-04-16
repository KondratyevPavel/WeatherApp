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

  /// 7 items
  var timestamps: [Int] { get }
  var timezone: TimeZone { get }
  func getDayWeather(for timestamp: Int) -> DayWeather?

  func refetchDataIfNeeded()
  func openDay(for timestamp: Int)
}


class WeatherOverviewViewController: UIViewController, WeatherOverviewViewControllerDelegateListener {

  private let model: WeatherOverviewViewControllerDelegate
  private lazy var todayView = createTodayView()
  private lazy var futureDayViews = createFutureDayViews()
  private lazy var todayDateFormatter = DateFormatterFactory.makeDate(timezone: model.timezone)
  private lazy var futureDateFormatter = DateFormatterFactory.makeWeekday(timezone: model.timezone)

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

    let todayButton = wrapInButton(view: todayView, index: 0, selector: #selector(dayPressed))
    todayButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(todayButton)

    NSLayoutConstraint.activate([
      bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      bottomPanel.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: LayoutConstants.bottomPanelHeight),

      todayButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      todayButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      todayButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      todayButton.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor)
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
    guard model.timestamps.count > 0 else { return }

    todayView.setup(
      with: model.getDayWeather(for: model.timestamps[0]),
      timestamp: model.timestamps[0],
      dateFormatter: todayDateFormatter
    )
    for (dayView, timestamp) in zip(futureDayViews, model.timestamps.dropFirst()) {
      dayView.setup(
        with: model.getDayWeather(for: timestamp),
        timestamp: timestamp,
        dateFormatter: futureDateFormatter
      )
    }
  }
}


// MARK: - Private
private extension WeatherOverviewViewController {

  func createBottomPanel() -> UIView {
    let bottomPanel = UIStackView()
    bottomPanel.isLayoutMarginsRelativeArrangement = true

    guard model.timestamps.count > 1 else { return bottomPanel }

    for index in 1..<model.timestamps.count {
      if index > 1 {
        let separator = createWrappedSeparator()
        separator.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.addArrangedSubview(separator)
      }
      let dayButton = wrapInButton(view: futureDayViews[index - 1], index: index, selector: #selector(dayPressed(_:)))
      dayButton.translatesAutoresizingMaskIntoConstraints = false
      bottomPanel.addArrangedSubview(dayButton)
      if index > 1 {
        futureDayViews[index - 1].widthAnchor.constraint(equalTo: futureDayViews[index - 2].widthAnchor).isActive = true
      }
    }

    return bottomPanel
  }

  func createTodayView() -> DayWeatherLargeView {
    let todayView = DayWeatherLargeView()
    return todayView
  }

  func createFutureDayViews() -> [DayWeatherSmallView] {
    guard model.timestamps.count > 1 else { return [] }

    let futureDayViews: [DayWeatherSmallView] = (1..<model.timestamps.count).map { _ in
      let view = DayWeatherSmallView()
      view.layoutMargins = UIEdgeInsets(
        top: LayoutConstants.spacing,
        left: 0,
        bottom: LayoutConstants.spacing,
        right: 0
      )
      return view
    }
    return futureDayViews
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

  func wrapInButton(view: UIView, index: Int, selector: Selector) -> UIButton {
    let button = UIButton()
    button.tag = index
    button.addTarget(self, action: selector, for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    button.addSubview(view)

    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: button.topAnchor),
      view.bottomAnchor.constraint(equalTo: button.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: button.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: button.trailingAnchor)
    ])

    return button
  }

  @objc
  func dayPressed(_ sender: UIButton) {
    guard sender.tag >= 0 && sender.tag < model.timestamps.count else { return }

    model.openDay(for: model.timestamps[sender.tag])
  }
}


// MARK: - LayoutConstants
private extension LayoutConstants {

  static let bottomPanelHeight: CGFloat = 100
}

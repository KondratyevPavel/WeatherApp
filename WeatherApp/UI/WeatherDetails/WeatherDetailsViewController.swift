//
//  WeatherDetailsViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import UIKit


protocol WeatherDetailsViewControllerDelegateListener {

  func hourlyWeatherChanged()
}


protocol WeatherDetailsViewControllerDelegate: Listenable {

  var hourlyWeather: [HourWeather?] { get }

  func refetchDataIfNeeded()
}


class WeatherDetailsViewController: UIViewController, WeatherDetailsViewControllerDelegateListener {

  private let model: WeatherDetailsViewControllerDelegate

  init(model: WeatherDetailsViewControllerDelegate) {
    self.model = model

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.backgroundColor = .systemBackground

    hourlyWeatherChanged()
    model.addListener(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    model.refetchDataIfNeeded()
  }

  // MARK: - WeatherDetailsViewControllerDelegateListener

  func hourlyWeatherChanged() {
  }
}

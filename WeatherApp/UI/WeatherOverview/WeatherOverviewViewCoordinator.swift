//
//  WeatherOverviewViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation
import UIKit


class WeatherOverviewViewCoordinator: WeatherOverviewViewModelDelegate, WeatherDetailsViewCoordinatorDelegate {

  typealias ViewModel = WeatherOverviewViewModel
  typealias ViewController = WeatherOverviewViewController
  typealias Injector = DailyWeatherDataManagerProvider & HourlyWeatherDataManagerProvider

  private weak var viewController: ViewController?
  private weak var viewModel: ViewModel?
  private let injector: Injector

  private init(injector: Injector) {
    self.injector = injector
  }

  static func build(injector: Injector) -> ViewController {
    let coordinator = WeatherOverviewViewCoordinator(injector: injector)
    let vm = ViewModel(injector: injector, coordinator: coordinator)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    return vc
  }

  // MARK: - WeatherOverviewViewModelDelegate

  func openWeatherDetails(with context: HourlyWeatherContext) {
    let vc = WeatherDetailsViewCoordinator.build(injector: injector, context: context, delegate: self)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = .pageSheet
    viewController?.present(nc, animated: true)
  }

  // MARK: -  WeatherDetailsViewCoordinatorDelegate

  func dismiss(coordinator: WeatherDetailsViewCoordinator) {
    viewController?.dismiss(animated: true)
  }
}

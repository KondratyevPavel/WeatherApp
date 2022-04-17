//
//  WeatherDetailsViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


protocol WeatherDetailsViewCoordinatorDelegate: AnyObject {

  func dismiss(coordinator: WeatherDetailsViewCoordinator)
}


class WeatherDetailsViewCoordinator: WeatherDetailsViewModelDelegate {

  typealias ViewModel = WeatherDetailsViewModel
  typealias ViewController = WeatherDetailsViewController
  typealias Injector = HourlyWeatherDataManagerProvider

  private weak var viewController: ViewController?
  private weak var viewModel: ViewModel?
  private weak var delegate: WeatherDetailsViewCoordinatorDelegate?

  static func build(
    injector: Injector,
    context: HourlyWeatherContext,
    delegate: WeatherDetailsViewCoordinatorDelegate
  ) -> ViewController {
    let coordinator = WeatherDetailsViewCoordinator()
    let vm = ViewModel(injector: injector, coordinator: coordinator, context: context)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    coordinator.delegate = delegate
    return vc
  }

  // MARK: - WeatherOverviewViewModelDelegate

  func closePressed() {
    delegate?.dismiss(coordinator: self)
  }
}

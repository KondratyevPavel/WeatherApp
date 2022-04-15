//
//  WeatherDetailsViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


class WeatherDetailsViewCoordinator: WeatherDetailsViewModelDelegate {

  typealias ViewModel = WeatherDetailsViewModel
  typealias ViewController = WeatherDetailsViewController
  typealias Injector = HourlyWeatherDataManagerProvider

  weak var viewController: ViewController?
  weak var viewModel: ViewModel?

  static func build(injector: Injector, context: HourlyWeatherContext) -> ViewController {
    let coordinator = WeatherDetailsViewCoordinator()
    let vm = ViewModel(injector: injector, coordinator: coordinator, context: context)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    return vc
  }

  // MARK: - WeatherOverviewViewModelDelegate
}

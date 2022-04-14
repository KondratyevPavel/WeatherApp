//
//  WeatherOverviewViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


class WeatherOverviewViewCoordinator: WeatherOverviewViewModelDelegate {

  typealias ViewModel = WeatherOverviewViewModel
  typealias ViewController = WeatherOverviewViewController

  weak var viewController: ViewController?
  weak var viewModel: ViewModel?

  static func build(injector: DailyWeatherDataManagerProvider) -> ViewController {
    let coordinator = WeatherOverviewViewCoordinator()
    let vm = ViewModel(injector: injector, coordinator: coordinator)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    return vc
  }

  // MARK: - WeatherOverviewViewModelDelegate
}

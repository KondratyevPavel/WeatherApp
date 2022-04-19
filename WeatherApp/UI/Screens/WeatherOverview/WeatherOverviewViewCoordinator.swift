//
//  WeatherOverviewViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class WeatherOverviewViewCoordinator: WeatherOverviewViewModelDelegate, WeatherDetailsViewCoordinatorDelegate, LocationViewCoordinatorDelegate, AboutViewCoordinatorDelegate {

  typealias ViewModel = WeatherOverviewViewModel
  typealias ViewController = WeatherOverviewViewController
  typealias Injector = DailyWeatherDataManagerProvider & HourlyWeatherDataManagerProvider & SettingsManagerProvider

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

  func dayPressed(with context: HourlyWeatherContext) {
    let vc = WeatherDetailsViewCoordinator.build(injector: injector, context: context, delegate: self)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = .pageSheet
    viewController?.present(nc, animated: true)
  }

  func locationPressed(with location: WeatherLocation) {
    let vc = LocationViewCoordinator.build(location: location, delegate: self)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = .pageSheet
    nc.presentationController?.delegate = vc
    nc.navigationBar.scrollEdgeAppearance = nc.navigationBar.standardAppearance
    viewController?.present(nc, animated: true)
  }

  func aboutPressed() {
    let vc = AboutViewCoordinator.build(delegate: self)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = .pageSheet
    nc.navigationBar.scrollEdgeAppearance = nc.navigationBar.standardAppearance
    viewController?.present(nc, animated: true)
  }

  // MARK: -  WeatherDetailsViewCoordinatorDelegate

  func dismiss(coordinator: WeatherDetailsViewCoordinator) {
    viewController?.dismiss(animated: true)
  }

  // MARK: - LocationViewCoordinatorDelegate

  func dismiss(coordinator: LocationViewCoordinator) {
    viewController?.dismiss(animated: true)
  }

  func dismiss(coordinator: LocationViewCoordinator, withSelectedLocation location: WeatherLocation) {
    saveLocation(location, coordinator: coordinator)
    dismiss(coordinator: coordinator)
  }

  func saveLocation(_ location: WeatherLocation, coordinator: LocationViewCoordinator) {
    viewModel?.setLocation(location)
  }

  // MARK: - AboutViewCoordinatorDelegate

  func dismiss(coordinator: AboutViewCoordinator) {
    viewController?.dismiss(animated: true)
  }
}

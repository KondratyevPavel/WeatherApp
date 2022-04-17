//
//  LocationViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import Foundation


protocol LocationViewCoordinatorDelegate: AnyObject {

  func dismiss(coordinator: LocationViewCoordinator)
  func dismiss(coordinator: LocationViewCoordinator, withSelectedLocation location: WeatherLocation)
  func saveLocation(_ location: WeatherLocation, coordinator: LocationViewCoordinator)
}


class LocationViewCoordinator: LocationViewModelDelegate {

  typealias ViewModel = LocationViewModel
  typealias ViewController = LocationViewController

  private weak var viewController: ViewController?
  private weak var viewModel: ViewModel?
  private weak var delegate: LocationViewCoordinatorDelegate?
  
  static func build(location: WeatherLocation, delegate: LocationViewCoordinatorDelegate) -> ViewController {
    let coordinator = LocationViewCoordinator()
    let vm = ViewModel(coordinator: coordinator, location: location)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    coordinator.delegate = delegate
    return vc
  }

  // MARK: - LocationViewModelDelegate

  func cancelPressed() {
    delegate?.dismiss(coordinator: self)
  }

  func donePressed(with location: WeatherLocation) {
    delegate?.dismiss(coordinator: self, withSelectedLocation: location)
  }

  func saveLocation(_ location: WeatherLocation) {
    delegate?.saveLocation(location, coordinator: self)
  }
}

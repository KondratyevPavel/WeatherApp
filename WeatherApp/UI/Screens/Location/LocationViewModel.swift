//
//  LocationViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import Foundation


protocol LocationViewModelDelegate {

  func cancelPressed()
  func donePressed(with location: WeatherLocation)
  func saveLocation(_ location: WeatherLocation)
}


class LocationViewModel: LocationViewControllerDelegate {

  private let coordinator: LocationViewModelDelegate
  private(set) var location: WeatherLocation

  init(coordinator: LocationViewModelDelegate, location: WeatherLocation) {
    self.coordinator = coordinator
    self.location = location
  }

  // MARK: - LocationViewControllerDelegate

  func setLocation(_ location: WeatherLocation) {
    self.location = location
  }

  func cancelPressed() {
    coordinator.cancelPressed()
  }

  func donePressed() {
    coordinator.donePressed(with: location)
  }

  func saveLocation() {
    coordinator.saveLocation(location)
  }
}

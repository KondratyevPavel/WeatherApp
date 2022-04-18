//
//  LocationViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import Foundation
import CoreLocation


protocol LocationViewModelDelegate {

  func cancelPressed()
  func donePressed(with location: WeatherLocation)
  func saveLocation(_ location: WeatherLocation)
}


class LocationViewModel: NSObject, LocationViewControllerDelegate, CLLocationManagerDelegate {

  private let coordinator: LocationViewModelDelegate
  private(set) var location: WeatherLocation
  private var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
  private lazy var locationManager = createLocationManager()

  init(coordinator: LocationViewModelDelegate, location: WeatherLocation) {
    self.coordinator = coordinator
    self.location = location
  }

  // MARK: - LocationViewControllerDelegate

  func setLocation(_ location: WeatherLocation) {
    self.location = location
  }

  func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
    self.completion = completion

    switch locationManager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    default:
      locationManager.requestLocation()
    }
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

  // MARK: - CLLocationManagerDelegate

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways,
        .authorizedWhenInUse:
      manager.requestLocation()
    case .denied,
        .restricted:
      completion = nil
    default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }

    completion?(.success(location.coordinate))
    completion = nil
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    completion?(.failure(error))
    completion = nil
  }
}


// MARK: - Private
private extension LocationViewModel {

  func createLocationManager() -> CLLocationManager {
    let locationManager = CLLocationManager()
    locationManager.delegate = self
    return locationManager
  }
}

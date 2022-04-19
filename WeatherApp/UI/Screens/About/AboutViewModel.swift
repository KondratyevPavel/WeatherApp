//
//  AboutViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 19.04.22.
//

import Foundation


protocol AboutViewModelDelegate {

  func exitPressed()
  func linkPressed(url: URL)
}


class AboutViewModel: AboutViewControllerDelegate {

  private let coordinator: AboutViewModelDelegate

  init(coordinator: AboutViewModelDelegate) {
    self.coordinator = coordinator
  }

  // MARK: - AboutViewControllerDelegate

  func exitPressed() {
    coordinator.exitPressed()
  }

  func dataProviderPressed() {
    coordinator.linkPressed(url: URL(string: "https://open-meteo.com/")!)
  }
}

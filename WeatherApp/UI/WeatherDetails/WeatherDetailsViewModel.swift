//
//  WeatherDetailsViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


protocol WeatherDetailsViewModelDelegate {
}


class WeatherDetailsViewModel: WeatherDetailsViewControllerDelegate, ListenableSupport, HourlyWeatherDataListener {

  typealias Injector = HourlyWeatherDataManagerProvider

  private let injector: Injector
  private let coordinator: WeatherDetailsViewModelDelegate
  private let hourlyWeatherDataManager: HourlyWeatherDataManagerProtocol
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(injector: Injector, coordinator: WeatherDetailsViewModelDelegate, context: HourlyWeatherContext) {
    self.injector = injector
    self.coordinator = coordinator
    self.hourlyWeatherDataManager = injector.getHourlyWeatherDataManager(context: context)

    hourlyWeatherDataManager.addListener(self)
  }

  // MARK: - WeatherOverviewViewControllerDelegate

  var hourlyWeather: [HourWeather?] { hourlyWeatherDataManager.hourlyWeather }

  func refetchDataIfNeeded() {
    hourlyWeatherDataManager.refetchDataIfNeeded()
  }

  // MARK: - HourlyWeatherDataListener

  func hourlyWeatherChanged() {
    notifyHourlyWeatherChanged()
  }
}


// MARK: - Private
private extension WeatherDetailsViewModel {

  func notifyHourlyWeatherChanged() {
    enumerateListeners { ($0 as? WeatherDetailsViewControllerDelegateListener)?.hourlyWeatherChanged() }
  }
}

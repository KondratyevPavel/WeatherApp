//
//  WeatherDetailsViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


protocol WeatherDetailsViewModelDelegate {
  
  func closePressed()
}


class WeatherDetailsViewModel: WeatherDetailsViewControllerDelegate, ListenableSupport, HourlyWeatherDataListener {

  typealias Injector = HourlyWeatherDataManagerProvider

  private let injector: Injector
  private let coordinator: WeatherDetailsViewModelDelegate
  private let hourlyWeatherDataManager: HourlyWeatherDataManagerProtocol
  let timezone: TimeZone
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(injector: Injector, coordinator: WeatherDetailsViewModelDelegate, context: HourlyWeatherContext) {
    self.injector = injector
    self.coordinator = coordinator
    self.hourlyWeatherDataManager = injector.getHourlyWeatherDataManager(context: context)
    self.timezone = context.timezone

    hourlyWeatherDataManager.addListener(self)
  }

  // MARK: - WeatherOverviewViewControllerDelegate

  var title: String {
    return DateFormatterFactory.makeDate(timezone: timezone)
      .string(from: Date(timeIntervalSince1970: timestamps[0]))
  }
  
  var timestamps: [Int] { hourlyWeatherDataManager.timestamps }

  func getHourWeather(for timestamp: Int) -> HourWeather? {
    return hourlyWeatherDataManager.getHourWeather(for: timestamp)
  }

  func refetchDataIfNeeded() {
    hourlyWeatherDataManager.refetchDataIfNeeded()
  }

  func closePressed() {
    coordinator.closePressed()
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

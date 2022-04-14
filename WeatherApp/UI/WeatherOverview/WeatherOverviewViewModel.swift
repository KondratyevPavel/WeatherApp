//
//  WeatherOverviewViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


protocol WeatherOverviewViewModelDelegate {
}


class WeatherOverviewViewModel: WeatherOverviewViewControllerDelegate, ListenableSupport, DailyWeatherDataListener {

  private let injector: DailyWeatherDataManagerProvider
  private let coordinator: WeatherOverviewViewModelDelegate
  private let dailyWeatherDataManager: DailyWeatherDataManagerProtocol
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(injector: DailyWeatherDataManagerProvider, coordinator: WeatherOverviewViewModelDelegate) {
    self.injector = injector
    self.coordinator = coordinator
    self.dailyWeatherDataManager = injector.getDailyWeatherDataManager(context: WeatherDataContext(location: WeatherLocation(latitude: 52.5235, longitude: 13.4115), timezone: .current))

    dailyWeatherDataManager.addListener(self)
  }

  // MARK: - WeatherOverviewViewControllerDelegate

  var dailyWeather: [DayWeather?] { dailyWeatherDataManager.dailyWeather }

  func refetchDataIfNeeded() {
    dailyWeatherDataManager.refetchDataIfNeeded()
  }

  // MARK: - DailyWeatherDataListener

  func dailyWeatherChanged() {
    notifyDailyWeatherChanged()
  }
}


// MARK: - Private
private extension WeatherOverviewViewModel {

  func notifyDailyWeatherChanged() {
    enumerateListeners { ($0 as? WeatherOverviewViewControllerDelegateListener)?.dailyWeatherChanged() }
  }
}

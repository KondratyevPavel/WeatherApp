//
//  WeatherOverviewViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


protocol WeatherOverviewViewModelDelegate {

  func dayPressed(with context: HourlyWeatherContext)
  func locationPressed(with location: WeatherLocation)
}


class WeatherOverviewViewModel: WeatherOverviewViewControllerDelegate, ListenableSupport, DailyWeatherDataListener {

  typealias Injector = DailyWeatherDataManagerProvider & SettingsManagerProvider

  private let injector: Injector
  private let coordinator: WeatherOverviewViewModelDelegate
  private let dailyWeatherDataManager: DailyWeatherDataManagerProtocol
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(injector: Injector, coordinator: WeatherOverviewViewModelDelegate) {
    self.injector = injector
    self.coordinator = coordinator
    let context = DailyWeatherContext(
      location: injector.settingsManager.weatherLocation,
      timezone: .current
    )
    self.dailyWeatherDataManager = injector.getDailyWeatherDataManager(context: context)

    dailyWeatherDataManager.addListener(self)
  }

  func setLocation(_ location: WeatherLocation) {
    injector.settingsManager.setWeatherLocation(location)
    dailyWeatherDataManager.setLocation(location)
  }

  // MARK: - WeatherOverviewViewControllerDelegate

  var timestamps: [Int] { dailyWeatherDataManager.timestamps }

  var timezone: TimeZone { dailyWeatherDataManager.timezone }

  func getDayWeather(for timestamp: Int) -> DayWeather? {
    return dailyWeatherDataManager.getDayWeather(for: timestamp)
  }

  func refetchDataIfNeeded() {
    dailyWeatherDataManager.refetchDataIfNeeded()
  }

  func dayPressed(with timestamp: Int) {
    let hourlyContext = dailyWeatherDataManager.getHourlyWeatherContext(for: timestamp)
    coordinator.dayPressed(with: hourlyContext)
  }

  func locationPressed() {
    coordinator.locationPressed(with: dailyWeatherDataManager.location)
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

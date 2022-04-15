//
//  HourlyWeatherDataManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation


protocol HourlyWeatherDataListener: AnyObject {

  func hourlyWeatherChanged()
}


protocol HourlyWeatherDataManagerProtocol: Listenable {

  /// 24 items
  var hourlyWeather: [HourWeather?] { get }

  func refetchDataIfNeeded()
}


class HourlyWeatherDataManager: HourlyWeatherDataManagerProtocol, ListenableSupport {

  private static let dataFetchMinimumIntervalSec: TimeInterval = 3 * 60 * 60

  private let context: HourlyWeatherContext
  private let serverAPIManager: ServerAPIManagerProtocol
  private let storageManager: StorageManagerProtocol
  private var lastFetchDate: Date
  var listeners: Set<AnyWeakHashedWrapper> = []
  private(set) var hourlyWeather: [HourWeather?] = Array(repeating: nil, count: DataConstants.hoursPerDay)
  private(set) var error: Error?

  init(context: HourlyWeatherContext, serverAPIManager: ServerAPIManagerProtocol, storageManager: StorageManagerProtocol) {
    self.context = context
    self.serverAPIManager = serverAPIManager
    self.storageManager = storageManager
    self.lastFetchDate = Date(timeIntervalSinceNow: -HourlyWeatherDataManager.dataFetchMinimumIntervalSec)

    fetchDataFromStore()
    fetchDataFromServer()
  }

  // MARK: - HourlyWeatherDataManagerProtocol

  func refetchDataIfNeeded() {
    guard needsToRefetchData else { return }

    fetchDataFromServer()
  }
}


// MARK: - Private
private extension HourlyWeatherDataManager {

  var needsToRefetchData: Bool {
    let now = Date()
    return (
      now.timeIntervalSince(lastFetchDate) >= HourlyWeatherDataManager.dataFetchMinimumIntervalSec
      || !now.sameDate(as: lastFetchDate, in: context.timezone)
    )
  }

  func fetchDataFromStore() {
    storageManager.getHourlyWeather(context: context) { [weak self] hourlyWeather in
      DispatchQueue.main.async {
        guard let self = self else { return }

        for index in 0..<DataConstants.daysPerWeek {
          self.hourlyWeather[index] = self.hourlyWeather[index] ?? hourlyWeather[index]
        }
        self.notifyHourlyWeatherChanged()
      }
    }
  }

  func fetchDataFromServer() {
    lastFetchDate = Date()

    serverAPIManager.getHourlyData(context: context) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }

        switch result {
        case let .success(hourlyWeather):
          self.hourlyWeather = hourlyWeather
          self.lastFetchDate = Date()
          self.notifyHourlyWeatherChanged()
          self.storageManager.saveHourlyWeather(location: self.context.location, hourlyWeather: hourlyWeather.compactMap { $0 })
        case let .failure(error):
          self.lastFetchDate = Date(timeIntervalSinceNow: -HourlyWeatherDataManager.dataFetchMinimumIntervalSec)
          print(error)
        }
      }
    }
  }

  func notifyHourlyWeatherChanged() {
    enumerateListeners { ($0 as? HourlyWeatherDataListener)?.hourlyWeatherChanged() }
  }
}

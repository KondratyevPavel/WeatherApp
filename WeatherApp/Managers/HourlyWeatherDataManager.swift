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
  var timestamps: [Int] { get }
  func getHourWeather(for timestamp: Int) -> HourWeather?

  func refetchDataIfNeeded()
}


class HourlyWeatherDataManager: HourlyWeatherDataManagerProtocol, ListenableSupport {

  private static let dataFetchMinimumIntervalSec: TimeInterval = 3 * 60 * 60

  private let context: HourlyWeatherContext
  private let serverAPIManager: ServerAPIManagerProtocol
  private let storageManager: StorageManagerProtocol
  let timestamps: [Int]
  private(set) var hourlyWeather: [Int: HourWeather] = [:]
  private var lastFetchDate: Date
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(
    context: HourlyWeatherContext,
    serverAPIManager: ServerAPIManagerProtocol,
    storageManager: StorageManagerProtocol
  ) {
    self.context = context
    self.serverAPIManager = serverAPIManager
    self.storageManager = storageManager
    self.timestamps = (0..<DataConstants.hoursPerDay)
      .map { context.timestamp + $0 * DataConstants.secondsPerHour}
    self.lastFetchDate = Date(timeIntervalSinceNow: -HourlyWeatherDataManager.dataFetchMinimumIntervalSec)

    fetchDataFromStore()
    fetchDataFromServer()
  }

  // MARK: - HourlyWeatherDataManagerProtocol

  func getHourWeather(for timestamp: Int) -> HourWeather? {
    return hourlyWeather[timestamp]
  }

  func refetchDataIfNeeded() {
    guard needsToRefetchData else { return }

    fetchDataFromServer()
  }
}


// MARK: - Private
private extension HourlyWeatherDataManager {

  var needsToRefetchData: Bool {
    return Date().timeIntervalSince(lastFetchDate) >= HourlyWeatherDataManager.dataFetchMinimumIntervalSec
  }

  func fetchDataFromStore() {
    storageManager.getHourlyWeather(location: context.location, timestamps: timestamps) { [weak self] hourlyWeather in
      DispatchQueue.main.async {
        guard let self = self else { return }

        hourlyWeather
          .filter { !self.hourlyWeather.keys.contains($0.timestamp) }
          .forEach { self.hourlyWeather[$0.timestamp] = $0 }
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
          let timestamps = Set(self.timestamps)
          self.hourlyWeather = hourlyWeather
            .filter { timestamps.contains($0.timestamp) }
            .makeDictionary(\.timestamp)
          self.lastFetchDate = Date()
          self.notifyHourlyWeatherChanged()
          self.storageManager.saveHourlyWeather(
            location: self.context.location,
            hourlyWeather: hourlyWeather
          )
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

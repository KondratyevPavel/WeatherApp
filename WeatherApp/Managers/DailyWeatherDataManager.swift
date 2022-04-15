//
//  DailyWeatherDataManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


protocol DailyWeatherDataListener: AnyObject {

  func dailyWeatherChanged()
}


protocol DailyWeatherDataManagerProtocol: Listenable {

  /// 7 items
  var dailyWeather: [DayWeather?] { get }

  func getHourlyWeatherContext(index: Int) -> HourlyWeatherContext
  func refetchDataIfNeeded()
}


class DailyWeatherDataManager: DailyWeatherDataManagerProtocol, ListenableSupport {

  private static let dataFetchMinimumIntervalSec: TimeInterval = 3 * 60 * 60

  private let context: DailyWeatherContext
  private let serverAPIManager: ServerAPIManagerProtocol
  private let storageManager: StorageManagerProtocol
  private var lastFetchDate: Date
  var listeners: Set<AnyWeakHashedWrapper> = []
  private(set) var dailyWeather: [DayWeather?] = Array(repeating: nil, count: DataConstants.daysPerWeek)
  private(set) var error: Error?

  init(context: DailyWeatherContext, serverAPIManager: ServerAPIManagerProtocol, storageManager: StorageManagerProtocol) {
    self.context = context
    self.serverAPIManager = serverAPIManager
    self.storageManager = storageManager
    self.lastFetchDate = Date(timeIntervalSinceNow: -DailyWeatherDataManager.dataFetchMinimumIntervalSec)

    fetchDataFromStore()
    fetchDataFromServer()
  }

  // MARK: - DailyWeatherDataManagerProtocol

  func getHourlyWeatherContext(index: Int) -> HourlyWeatherContext {
    let initialTimestamp = dailyWeather.first??.timestamp ?? Date().getMidnightTimestamp(in: context.timezone)
    return HourlyWeatherContext(
      location: context.location,
      timezone: context.timezone,
      initialTimestamp: initialTimestamp + index * DataConstants.secondsPerDay
    )
  }

  func refetchDataIfNeeded() {
    guard needsToRefetchData else { return }

    fetchDataFromServer()
  }
}


// MARK: - Private
private extension DailyWeatherDataManager {

  var needsToRefetchData: Bool {
    let now = Date()
    return (
      now.timeIntervalSince(lastFetchDate) >= DailyWeatherDataManager.dataFetchMinimumIntervalSec
      || !now.sameDate(as: lastFetchDate, in: context.timezone)
    )
  }

  func fetchDataFromStore() {
    storageManager.getDailyWeather(context: context) { [weak self] dailyWeather in
      DispatchQueue.main.async {
        guard let self = self else { return }

        for index in 0..<DataConstants.daysPerWeek {
          self.dailyWeather[index] = self.dailyWeather[index] ?? dailyWeather[index]
        }
        self.notifyDailyWeatherChanged()
      }
    }
  }

  func fetchDataFromServer() {
    lastFetchDate = Date()

    serverAPIManager.getDailyData(context: context) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }

        switch result {
        case let .success(dailyWeather):
          self.dailyWeather = dailyWeather
          self.lastFetchDate = Date()
          self.notifyDailyWeatherChanged()
          self.storageManager.saveDailyWeather(location: self.context.location, dailyWeather: dailyWeather.compactMap { $0 })
        case let .failure(error):
          self.lastFetchDate = Date(timeIntervalSinceNow: -DailyWeatherDataManager.dataFetchMinimumIntervalSec)
          print(error)
        }
      }
    }
  }

  func notifyDailyWeatherChanged() {
    enumerateListeners { ($0 as? DailyWeatherDataListener)?.dailyWeatherChanged() }
  }
}

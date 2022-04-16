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

  var timezone: TimeZone { get }
  /// 7 items
  var timestamps: [Int] { get }
  func getDayWeather(for timestamp: Int) -> DayWeather?

  func getHourlyWeatherContext(for timestamp: Int) -> HourlyWeatherContext
  func refetchDataIfNeeded()
}


class DailyWeatherDataManager: DailyWeatherDataManagerProtocol, ListenableSupport {

  private static let dataFetchMinimumIntervalSec: TimeInterval = 3 * 60 * 60

  private var context: DailyWeatherContext
  private let serverAPIManager: ServerAPIManagerProtocol
  private let storageManager: StorageManagerProtocol
  private(set) var timestamps: [Int]  // count must be equal to DataConstants.daysPerWeek
  private var dailyWeather: [Int: DayWeather] = [:]
  private var lastFetchDate: Date
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(context: DailyWeatherContext, serverAPIManager: ServerAPIManagerProtocol, storageManager: StorageManagerProtocol) {
    self.context = context
    self.serverAPIManager = serverAPIManager
    self.storageManager = storageManager
    self.timestamps = DailyWeatherDataManager.generateWeekTimestamps(in: context.timezone)
    self.lastFetchDate = Date(timeIntervalSinceNow: -DailyWeatherDataManager.dataFetchMinimumIntervalSec)

    fetchDataFromStore()
    fetchDataFromServer()
  }

  // MARK: - DailyWeatherDataManagerProtocol

  var timezone: TimeZone { context.timezone }
  
  func getHourlyWeatherContext(for timestamp: Int) -> HourlyWeatherContext {
    return HourlyWeatherContext(
      location: context.location,
      timezone: context.timezone,
      timestamp: timestamp
    )
  }

  func getDayWeather(for timestamp: Int) -> DayWeather? {
    return dailyWeather[timestamp]
  }

  func refetchDataIfNeeded() {
    guard needsToRefetchData else { return }

    fetchDataFromServer()
  }
}


// MARK: - Private
private extension DailyWeatherDataManager {

  static func generateWeekTimestamps(in timezone: TimeZone) -> [Int] {
    let initialTimestamp = Date().getMidnightTimestamp(in: timezone)
    let timestamps = (0..<DataConstants.daysPerWeek).map { initialTimestamp + $0 * DataConstants.secondsPerDay }
    return timestamps
  }

  var needsToRefetchData: Bool {
    let now = Date()
    return (
      now.timeIntervalSince(lastFetchDate) >= DailyWeatherDataManager.dataFetchMinimumIntervalSec
      || !now.sameDate(as: lastFetchDate, in: context.timezone)
    )
  }

  func fetchDataFromStore() {
    let context = self.context
    storageManager.getDailyWeather(location: context.location, timestamps: timestamps) { [weak self] dailyWeather in
      DispatchQueue.main.async {
        guard
          let self = self,
          self.context == context
        else { return }

        let timestamps = Set(self.timestamps)
        dailyWeather
          .filter { timestamps.contains($0.timestamp) && !self.dailyWeather.keys.contains($0.timestamp) }
          .forEach { self.dailyWeather[$0.timestamp] = $0 }
        self.notifyDailyWeatherChanged()
      }
    }
  }

  func fetchDataFromServer() {
    lastFetchDate = Date()
    let context = self.context

    serverAPIManager.getDailyData(context: context) { [weak self] result in
      DispatchQueue.main.async {
        guard
          let self = self,
          self.context == context
        else { return }

        switch result {
        case let .success(dailyWeather):
          self.timestamps = DailyWeatherDataManager.generateWeekTimestamps(in: self.context.timezone)
          let timestamps = Set(self.timestamps)
          self.dailyWeather = dailyWeather
            .filter { timestamps.contains($0.timestamp) }
            .makeDictionary(\.timestamp)
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

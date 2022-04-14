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

  func refetchDataIfNeeded()
}


class DailyWeatherDataManager: DailyWeatherDataManagerProtocol, ListenableSupport {

  private static let dataFetchMinimumIntervalSec: TimeInterval = 3 * 60 * 60

  private let context: WeatherDataContext
  private let serverAPIManager: ServerAPIManagerProtocol
  private var lastFetchDate: Date
  var listeners: Set<AnyWeakHashedWrapper> = []
  private(set) var dailyWeather: [DayWeather?] = Array(repeating: nil, count: DataConstants.weatherDaysCount)
  private(set) var error: Error?

  init(context: WeatherDataContext, serverAPIManager: ServerAPIManagerProtocol) {
    self.context = context
    self.serverAPIManager = serverAPIManager
    self.lastFetchDate = Date(timeIntervalSinceNow: -DailyWeatherDataManager.dataFetchMinimumIntervalSec)
    
    fetchDataFromServer()
  }

  // MARK: - DailyWeatherDataManagerProtocol

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

  func fetchDataFromServer() {
    serverAPIManager.getDailyData(context: context) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }

        switch result {
        case let .success(dailyWeather):
          self.dailyWeather = dailyWeather
          self.notifyDailyWeatherChanged()
        case let .failure(error):
          print(error)
        }
      }
    }
  }

  func notifyDailyWeatherChanged() {
    enumerateListeners { ($0 as? DailyWeatherDataListener)?.dailyWeatherChanged() }
  }
}

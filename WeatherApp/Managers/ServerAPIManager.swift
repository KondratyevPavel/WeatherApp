//
//  ServerAPIManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


enum ServerAPIManagerError: Error {
}


protocol ServerAPIManagerProtocol {

  /// returns 7 days data
  func getDailyData(context: WeatherDataContext, completion: @escaping (Result<[DayWeather], ServerAPIManagerError>) -> Void)
}


class ServerAPIManager: ServerAPIManagerProtocol {

  // MARK: - ServerAPIManagerProtocol

  func getDailyData(context: WeatherDataContext, completion: @escaping (Result<[DayWeather], ServerAPIManagerError>) -> Void) {
    DispatchQueue.global().async {
      let startDate = Date().getMidnight(in: context.timezone)
      completion(.success((0..<7).map { DayWeather(
        timestamp: Int(clamping: startDate.timeIntervalSince1970) + $0 * 24 * 60 * 60,
        minTemperatureC: 10,
        maxTemperatureC: 20,
        weatherType: .clear
      ) }))
    }
  }
}

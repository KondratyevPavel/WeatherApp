//
//  ServerAPIManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


enum ServerAPIManagerError: Error {
  case
  failedToBuildRequest,
  requestFailed,
  invalidResponseData
}


protocol ServerAPIManagerProtocol {

  /// returns 7 days data
  func getDailyData(context: DailyWeatherContext, completion: @escaping (Result<[DayWeather], ServerAPIManagerError>) -> Void)

  /// returns 24x7 hours data
  func getHourlyData(context: HourlyWeatherContext, completion: @escaping (Result<[HourWeather], ServerAPIManagerError>) -> Void)
}


class ServerAPIManager: ServerAPIManagerProtocol {

  private let session = URLSession(configuration: .default)

  // MARK: - ServerAPIManagerProtocol

  func getDailyData(context: DailyWeatherContext, completion: @escaping (Result<[DayWeather], ServerAPIManagerError>) -> Void) {
    var requestComponents = URLComponents()
    requestComponents.host = "api.open-meteo.com"
    requestComponents.scheme = "https"
    requestComponents.path = "/v1/forecast"
    requestComponents.queryItems = [
      URLQueryItem(name: "latitude", value: "\(context.location.latitude)"),
      URLQueryItem(name: "longitude", value: "\(context.location.longitude)"),
      URLQueryItem(name: "timezone", value: context.timezone.identifier),
      URLQueryItem(name: "daily", value: "weathercode,temperature_2m_max,temperature_2m_min")
    ]
    guard let request = requestComponents.url else {
      completion(.failure(.failedToBuildRequest))
      return
    }

    session.dataTask(with: request, completionHandler: { data, response, error in
      guard let data = data else {
        completion(.failure(.requestFailed))
        return
      }

      guard
        let response = try? DailyDataResponse(jsonData: data, timezone: context.timezone),
        let dailyWeather = response.makeDailyWeather()
      else {
        completion(.failure(.invalidResponseData))
        return
      }

      completion(.success(dailyWeather))
    }).resume()
  }

  func getHourlyData(context: HourlyWeatherContext, completion: @escaping (Result<[HourWeather], ServerAPIManagerError>) -> Void) {
    var requestComponents = URLComponents()
    requestComponents.host = "api.open-meteo.com"
    requestComponents.scheme = "https"
    requestComponents.path = "/v1/forecast"
    requestComponents.queryItems = [
      URLQueryItem(name: "latitude", value: "\(context.location.latitude)"),
      URLQueryItem(name: "longitude", value: "\(context.location.longitude)"),
      URLQueryItem(name: "timezone", value: context.timezone.identifier),
      URLQueryItem(name: "hourly", value: "temperature_2m,weathercode")
    ]
    guard let request = requestComponents.url else {
      completion(.failure(.failedToBuildRequest))
      return
    }

    session.dataTask(with: request, completionHandler: { data, response, error in
      guard let data = data else {
        completion(.failure(.requestFailed))
        return
      }

      guard
        let response = try? HourlyDataResponse(jsonData: data, timezone: context.timezone),
        let hourlyWeather = response.makeHourlyWeather()
      else {
        completion(.failure(.invalidResponseData))
        return
      }

      completion(.success(hourlyWeather))
    }).resume()
  }
}


// MARK: - Private
private extension ServerAPIManager {

  struct DailyDataResponse: Codable {

    var daily: DailyData

    init(jsonData: Data, timezone: TimeZone) throws {
      let decoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = timezone
      dateFormatter.dateFormat = "yyyy-MM-dd"
      decoder.dateDecodingStrategy = .formatted(dateFormatter)
      self = try decoder.decode(DailyDataResponse.self, from: jsonData)
    }

    func makeDailyWeather() -> [DayWeather]? {
      guard
        daily.temperature_2m_max.count == DataConstants.daysPerWeek
          && daily.temperature_2m_min.count == DataConstants.daysPerWeek
          && daily.weathercode.count == DataConstants.daysPerWeek
          && daily.time.count == DataConstants.daysPerWeek
      else { return nil }

      let dailyWeather: [DayWeather] = (0..<DataConstants.daysPerWeek)
        .map { DayWeather(
          timestamp: Int(clamping: daily.time[$0].timeIntervalSince1970, rule: .toNearestOrAwayFromZero),
          minTemperatureC: daily.temperature_2m_min[$0],
          maxTemperatureC: daily.temperature_2m_max[$0],
          weatherType: WeatherType(serverValue: daily.weathercode[$0])
        ) }
      return dailyWeather
    }

    struct DailyData: Codable {

      var temperature_2m_max: [Double]
      var temperature_2m_min: [Double]
      var weathercode: [Int]
      var time: [Date]
    }
  }

  struct HourlyDataResponse: Codable {

    var hourly: HourlyData

    init(jsonData: Data, timezone: TimeZone) throws {
      let decoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = timezone
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
      decoder.dateDecodingStrategy = .formatted(dateFormatter)
      self = try decoder.decode(HourlyDataResponse.self, from: jsonData)
    }

    func makeHourlyWeather() -> [HourWeather]? {
      return nil
    }

    struct HourlyData: Codable {

      var temperature_2m: [Double]
      var weathercode: [Int]
      var time: [Date]
    }
  }
}


private extension WeatherType {

  init(serverValue: Int) {
    switch serverValue {
    case 0, 1:
      self = .clear
    case 2, 3, 45, 48:
      self = .cloudy
    default:
      self = .rain
    }
  }
}

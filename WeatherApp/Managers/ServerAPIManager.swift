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

      guard let response = try? DailyDataResponse(jsonData: data, timezone: context.timezone) else {
        completion(.failure(.invalidResponseData))
        return
      }

      let result = response.makeDailyWeather()
      completion(.success(result))
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

      guard let response = try? HourlyDataResponse(jsonData: data, timezone: context.timezone) else {
        completion(.failure(.invalidResponseData))
        return
      }

      let result = response.makeHourlyWeather()
      completion(.success(result))
    }).resume()
  }
}


// MARK: - Private
private extension ServerAPIManager {

  struct DailyDataResponse: Codable {

    var daily: DailyData

    init(jsonData: Data, timezone: TimeZone) throws {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .formatted(DateFormatterFactory.makeServerDate(timezone: timezone))
      self = try decoder.decode(DailyDataResponse.self, from: jsonData)
    }

    func makeDailyWeather() -> [DayWeather] {
      let daysCount = min(
        daily.time.count,
        daily.weathercode.count,
        daily.temperature_2m_min.count,
        daily.temperature_2m_max.count
      )
      let result = (0..<daysCount).map { DayWeather(
        timestamp: Int(clamping: daily.time[$0].timeIntervalSince1970, rule: .toNearestOrAwayFromZero),
        minTemperatureC: daily.temperature_2m_min[$0],
        maxTemperatureC: daily.temperature_2m_max[$0],
        weatherType: WeatherType(serverValue: daily.weathercode[$0])
      ) }
      return result
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
      decoder.dateDecodingStrategy = .formatted(DateFormatterFactory.makeServerDateTime(timezone: timezone))
      self = try decoder.decode(HourlyDataResponse.self, from: jsonData)
    }

    func makeHourlyWeather() -> [HourWeather] {
      let hoursCount = min(hourly.time.count, hourly.weathercode.count, hourly.temperature_2m.count)
      let result = (0..<hoursCount).map { HourWeather(
        timestamp: Int(clamping: hourly.time[$0].timeIntervalSince1970, rule: .toNearestOrAwayFromZero),
        temperatureC: hourly.temperature_2m[$0],
        weatherType: WeatherType(serverValue: hourly.weathercode[$0])
      ) }
      return result
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
    case 2:
      self = .semiCloudy
    case 3:
      self = .cloudy
    case 45, 48:
      self = .fog
    case 51, 52, 53, 56, 57:
      self = .drizzle
    case 61:
      self = .lightRain
    case 63, 66:
      self = .rain
    case 65, 67:
      self = .heavyRain
    case 71, 73, 75, 77:
      self = .snow
    case 80, 81, 82:
      self = .rain
    case 85, 86:
      self = .snow
    case 95:
      self = .rainBolt
    case 96, 99:
      self = .hail
    default:
      self = .clear
    }
  }
}

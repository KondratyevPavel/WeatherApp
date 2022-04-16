//
//  StorageManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


protocol StorageManagerProtocol {

  func getDailyWeather(location: WeatherLocation, timestamps: [Int], completion: @escaping ([DayWeather]) -> Void)
  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather])

  func getHourlyWeather(location: WeatherLocation, timestamps: [Int], completion: @escaping ([HourWeather]) -> Void)
  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather])

  func clearOldData()
}


class StorageManager: StorageManagerProtocol {

  private static let storeLocation = (try! FileManager.default.url(
    for: .documentDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true
  )).appendingPathComponent("store.sqlite")

  private let context: NSManagedObjectContext

  init() {
    let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    _ = try? coordinator.addPersistentStore(
      ofType: NSSQLiteStoreType,
      configurationName: nil,
      at: StorageManager.storeLocation
    )
    self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    self.context.persistentStoreCoordinator = coordinator
  }

  // MARK: - StorageManagerProtocol

  func getDailyWeather(location: WeatherLocation, timestamps: [Int], completion: @escaping ([DayWeather]) -> Void) {
    context.perform { [self] in
      defer { context.reset() }

      let request = DayWeatherEntity.fetchRequest()
      request.returnsObjectsAsFaults = false
      request.fetchLimit = timestamps.count
      request.predicate = NSPredicate(
        format: "location.latitude == %lf && location.longitude == %lf && timestamp in %@",
        location.latitude,
        location.longitude,
        timestamps
      )
      guard let entities = try? context.fetch(request) else {
        completion([])
        return
      }

      let result = entities.compactMap { $0.makeModel() }
      completion(result)
    }
  }

  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather]) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      locationRequest.fetchLimit = 1
      let location = ((try? context.fetch(locationRequest).first)
                      ?? WeatherLocationEntity(context: context, model: location))

      let dailyWeatherRequest = DayWeatherEntity.fetchRequest()
      dailyWeatherRequest.returnsObjectsAsFaults = false
      dailyWeatherRequest.fetchLimit = dailyWeather.count
      dailyWeatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        location,
        dailyWeather.map { $0.timestamp }
      )
      guard let entities = try? context.fetch(dailyWeatherRequest) else { return }

      var entitiesRegistry = entities.makeDictionary { Int($0.timestamp) }
      for dayWeather in dailyWeather {
        if let entity = entitiesRegistry[dayWeather.timestamp] {
          entity.update(with: dayWeather)
        } else {
          entitiesRegistry[dayWeather.timestamp] = DayWeatherEntity(
            context: context,
            model: dayWeather,
            location: location
          )
        }
      }
      try? context.save()
    }
  }

  func getHourlyWeather(location: WeatherLocation, timestamps: [Int], completion: @escaping ([HourWeather]) -> Void) {
    context.perform { [self] in
      defer { context.reset() }

      let request = HourWeatherEntity.fetchRequest()
      request.returnsObjectsAsFaults = false
      request.fetchLimit = timestamps.count
      request.predicate = NSPredicate(
        format: "location.latitude == %lf && location.longitude == %lf && timestamp in %@",
        location.latitude,
        location.longitude,
        timestamps
      )
      guard let entities = try? context.fetch(request) else {
        completion([])
        return
      }

      let result = entities.compactMap { $0.makeModel() }
      completion(result)
    }
  }

  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather]) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      locationRequest.fetchLimit = 1
      let location = ((try? context.fetch(locationRequest).first)
                      ?? WeatherLocationEntity(context: context, model: location))

      let hourlyWeatherRequest = HourWeatherEntity.fetchRequest()
      hourlyWeatherRequest.returnsObjectsAsFaults = false
      hourlyWeatherRequest.fetchLimit = hourlyWeather.count
      hourlyWeatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        location,
        hourlyWeather.map { $0.timestamp }
      )
      guard let entities = try? context.fetch(hourlyWeatherRequest) else { return }

      var entitiesRegistry = entities.makeDictionary { Int($0.timestamp) }
      for hourWeather in hourlyWeather {
        if let entity = entitiesRegistry[hourWeather.timestamp] {
          entity.update(with: hourWeather)
        } else {
          entitiesRegistry[hourWeather.timestamp] = HourWeatherEntity(
            context: context,
            model: hourWeather,
            location: location
          )
        }
      }
      try? context.save()
    }
  }

  func clearOldData() {
    context.perform { [self] in
      defer { context.reset() }

      let timestamp = Date().getMidnightTimestamp(in: TimeZone(secondsFromGMT: DataConstants.minTimezoneOffset)!)

      let dayWeatherRequest = DayWeatherEntity.fetchRequest()
      dayWeatherRequest.predicate = NSPredicate(format: "timestamp < %d", timestamp)
      if let entities = try? context.fetch(dayWeatherRequest) {
        entities.forEach { context.delete($0) }
      }

      let hourlyWeatherRequest = HourWeatherEntity.fetchRequest()
      hourlyWeatherRequest.predicate = NSPredicate(format: "timestamp < %d", timestamp)
      if let entities = try? context.fetch(hourlyWeatherRequest) {
        entities.forEach { context.delete($0) }
      }

      try? context.save()

      let weatherLocationsRequest: NSFetchRequest<NSFetchRequestResult> = WeatherLocationEntity.fetchRequest()
      weatherLocationsRequest.predicate = NSPredicate(format: "dailyWeather.@count == 0 && hourlyWeather.@count == 0")
      let weatherLocationsDeleteRequest = NSBatchDeleteRequest(fetchRequest: weatherLocationsRequest)
      _ = try? context.execute(weatherLocationsDeleteRequest)
    }
  }
}

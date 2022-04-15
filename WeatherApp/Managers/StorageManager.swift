//
//  StorageManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


protocol StorageManagerProtocol {

  func getDailyWeather(context: DailyWeatherContext, completion: @escaping ([DayWeather?]) -> Void)
  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather])

  func getHourlyWeather(context: HourlyWeatherContext, completion: @escaping ([HourWeather?]) -> Void)
  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather])
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

  func getDailyWeather(context: DailyWeatherContext, completion: @escaping ([DayWeather?]) -> Void) {
    self.context.perform { [self] in
      let request = DayWeatherEntity.fetchRequest()
      let initialTimestamp = Date().getMidnightTimestamp(in: context.timezone)
      let timestamps = (0..<DataConstants.daysPerWeek).map { initialTimestamp + $0 * DataConstants.secondsPerDay }
      request.predicate = NSPredicate(
        format: "location.latitude == %lf && location.longitude == %lf && timestamp in %@",
        context.location.latitude,
        context.location.longitude,
        timestamps
      )
      request.fetchLimit = timestamps.count
      let entities = (try? self.context.fetch(request)) ?? []
      let entitiesRegistry = entities.reduce(into: [Int64: DayWeatherEntity](), { $0[$1.timestamp] = $1 })
      let result = timestamps.map { timestamp in entitiesRegistry[Int64(timestamp)].flatMap { $0.makeModel() }}
      completion(result)
    }
  }

  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather]) {
    context.perform { [self] in
      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      locationRequest.fetchLimit = 1
      let location = ((try? context.fetch(locationRequest).first)
                      ?? WeatherLocationEntity(context: context, model: location))
      let dayWeatherRequest = DayWeatherEntity.fetchRequest()
      dayWeatherRequest.fetchLimit = 1
      for dayWeather in dailyWeather {
        dayWeatherRequest.predicate = NSPredicate(format: "location == %@ && timestamp == %d", location, dayWeather.timestamp)
        if let entity = try? context.fetch(dayWeatherRequest).first {
          entity.update(with: dayWeather)
        } else {
          _ = DayWeatherEntity(context: context, model: dayWeather, location: location)
        }
      }
      try? context.save()
    }
  }

  func getHourlyWeather(context: HourlyWeatherContext, completion: @escaping ([HourWeather?]) -> Void) {
    self.context.perform { [self] in
      let request = HourWeatherEntity.fetchRequest()
      let timestamps = (0..<DataConstants.hoursPerDay).map { context.initialTimestamp + $0 * DataConstants.secondsPerHour }
      request.predicate = NSPredicate(
        format: "location.latitude == %lf && location.longitude == %lf && timestamp in %@",
        context.location.latitude,
        context.location.longitude,
        timestamps
      )
      request.fetchLimit = timestamps.count
      let entities = (try? self.context.fetch(request)) ?? []
      let entitiesRegistry = entities.reduce(into: [Int64: HourWeatherEntity](), { $0[$1.timestamp] = $1 })
      let result = timestamps.map { timestamp in entitiesRegistry[Int64(timestamp)].flatMap { $0.makeModel() }}
      completion(result)
    }
  }

  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather]) {
    context.perform { [self] in
      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      locationRequest.fetchLimit = 1
      let location = ((try? context.fetch(locationRequest).first)
                      ?? WeatherLocationEntity(context: context, model: location))
      let hourWeatherRequest = HourWeatherEntity.fetchRequest()
      hourWeatherRequest.fetchLimit = 1
      for hourWeather in hourlyWeather {
        hourWeatherRequest.predicate = NSPredicate(format: "location == %@ && timestamp == %d", location, hourWeather.timestamp)
        if let entity = try? context.fetch(hourWeatherRequest).first {
          entity.update(with: hourWeather)
        } else {
          _ = HourWeatherEntity(context: context, model: hourWeather, location: location)
        }
      }
      try? context.save()
    }
  }
}

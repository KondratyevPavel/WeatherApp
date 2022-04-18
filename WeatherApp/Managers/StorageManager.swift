//
//  StorageManager.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


protocol StorageManagerProtocol {

  typealias GetDailyWeatherCompletion = (_ dailyWeather: [DayWeather], _ fetchDate: Date) -> Void
  typealias GetHourlyWeatherCompletion = (_ dailyWeather: [HourWeather], _ fetchDate: Date) -> Void

  func getDailyWeather(
    location: WeatherLocation,
    timestamps: [Int],
    completion: @escaping GetDailyWeatherCompletion
  )
  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather], fetchDate: Date)

  func getHourlyWeather(
    location: WeatherLocation,
    timestamps: [Int],
    completion: @escaping GetHourlyWeatherCompletion
  )
  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather], fetchDate: Date)

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
    do {
      try coordinator.addPersistentStore(
        ofType: NSSQLiteStoreType,
        configurationName: nil,
        at: StorageManager.storeLocation
      )
    } catch {
      print(error)
    }
    self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    self.context.persistentStoreCoordinator = coordinator
  }

  // MARK: - StorageManagerProtocol

  func getDailyWeather(
    location: WeatherLocation,
    timestamps: [Int],
    completion: @escaping GetDailyWeatherCompletion
  ) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.returnsObjectsAsFaults = false
      locationRequest.fetchLimit = 1
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      guard
        let locationEntity = (try? context.fetch(locationRequest))?.first,
        let fetchDate = locationEntity.dailyWeatherTimestamp
      else {
        completion([], .distantPast)
        return
      }

      let weatherRequest = DayWeatherEntity.fetchRequest()
      weatherRequest.returnsObjectsAsFaults = false
      weatherRequest.fetchLimit = timestamps.count
      weatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        locationEntity,
        timestamps
      )
      guard let weatherEntities = try? context.fetch(weatherRequest) else {
        completion([], fetchDate)
        return
      }

      let dailyWeather = weatherEntities.compactMap { $0.makeModel() }
      completion(dailyWeather, fetchDate)
    }
  }

  func saveDailyWeather(location: WeatherLocation, dailyWeather: [DayWeather], fetchDate: Date) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.returnsObjectsAsFaults = false
      locationRequest.fetchLimit = 1
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      let locationEntity = ((try? context.fetch(locationRequest).first)
                            ?? WeatherLocationEntity(context: context, model: location))
      locationEntity.dailyWeatherTimestamp = fetchDate

      let weatherRequest = DayWeatherEntity.fetchRequest()
      weatherRequest.returnsObjectsAsFaults = false
      weatherRequest.fetchLimit = dailyWeather.count
      weatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        locationEntity,
        dailyWeather.map { $0.timestamp }
      )
      guard let weatherEntities = try? context.fetch(weatherRequest) else { return }

      var weatherEntitiesRegistry = weatherEntities.makeDictionary { Int($0.timestamp) }
      for dayWeather in dailyWeather {
        if let weatherEntity = weatherEntitiesRegistry[dayWeather.timestamp] {
          weatherEntity.update(with: dayWeather)
        } else {
          weatherEntitiesRegistry[dayWeather.timestamp] = DayWeatherEntity(
            context: context,
            model: dayWeather,
            location: locationEntity
          )
        }
      }
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }

  func getHourlyWeather(
    location: WeatherLocation,
    timestamps: [Int],
    completion: @escaping GetHourlyWeatherCompletion
  ) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.returnsObjectsAsFaults = false
      locationRequest.fetchLimit = 1
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      guard
        let locationEntity = (try? context.fetch(locationRequest))?.first,
        let fetchDate = locationEntity.hourlyWeatherTimestamp
      else {
        completion([], .distantPast)
        return
      }

      let weatherRequest = HourWeatherEntity.fetchRequest()
      weatherRequest.returnsObjectsAsFaults = false
      weatherRequest.fetchLimit = timestamps.count
      weatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        locationEntity,
        timestamps
      )
      guard let weatherEntities = try? context.fetch(weatherRequest) else {
        completion([], fetchDate)
        return
      }

      let hourlyWeather = weatherEntities.compactMap { $0.makeModel() }
      completion(hourlyWeather, fetchDate)
    }
  }

  func saveHourlyWeather(location: WeatherLocation, hourlyWeather: [HourWeather], fetchDate: Date) {
    context.perform { [self] in
      defer { context.reset() }

      let locationRequest = WeatherLocationEntity.fetchRequest()
      locationRequest.returnsObjectsAsFaults = false
      locationRequest.fetchLimit = 1
      locationRequest.predicate = NSPredicate(
        format: "latitude == %lf && longitude == %lf",
        location.latitude,
        location.longitude
      )
      let locationEntity = ((try? context.fetch(locationRequest).first)
                            ?? WeatherLocationEntity(context: context, model: location))
      locationEntity.hourlyWeatherTimestamp = fetchDate

      let weatherRequest = HourWeatherEntity.fetchRequest()
      weatherRequest.returnsObjectsAsFaults = false
      weatherRequest.fetchLimit = hourlyWeather.count
      weatherRequest.predicate = NSPredicate(
        format: "location == %@ && timestamp in %@",
        locationEntity,
        hourlyWeather.map { $0.timestamp }
      )
      guard let weatherEntities = try? context.fetch(weatherRequest) else { return }

      var weatherEntitiesRegistry = weatherEntities.makeDictionary { Int($0.timestamp) }
      for hourWeather in hourlyWeather {
        if let weatherEntity = weatherEntitiesRegistry[hourWeather.timestamp] {
          weatherEntity.update(with: hourWeather)
        } else {
          weatherEntitiesRegistry[hourWeather.timestamp] = HourWeatherEntity(
            context: context,
            model: hourWeather,
            location: locationEntity
          )
        }
      }
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }

  func clearOldData() {
    context.perform { [self] in
      defer { context.reset() }

      let timestamp = Date().getMidnightTimestamp(in: TimeZone(secondsFromGMT: DataConstants.minTimezoneOffset)!)

      let daylyWeatherRequest = DayWeatherEntity.fetchRequest()
      daylyWeatherRequest.predicate = NSPredicate(format: "timestamp < %d", timestamp)
      if let entities = try? context.fetch(daylyWeatherRequest) {
        entities.forEach { context.delete($0) }
      }

      let hourlyWeatherRequest = HourWeatherEntity.fetchRequest()
      hourlyWeatherRequest.predicate = NSPredicate(format: "timestamp < %d", timestamp)
      if let entities = try? context.fetch(hourlyWeatherRequest) {
        entities.forEach { context.delete($0) }
      }

      do {
        try context.save()
      } catch {
        print(error)
      }

      let weatherLocationsRequest: NSFetchRequest<NSFetchRequestResult> = WeatherLocationEntity.fetchRequest()
      weatherLocationsRequest.predicate = NSPredicate(format: "dailyWeather.@count == 0 && hourlyWeather.@count == 0")
      let weatherLocationsDeleteRequest = NSBatchDeleteRequest(fetchRequest: weatherLocationsRequest)

      do {
        try context.execute(weatherLocationsDeleteRequest)
      } catch {
        print(error)
      }
    }
  }
}

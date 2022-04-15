//
//  Injector.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


protocol DailyWeatherDataManagerProvider {

  func getDailyWeatherDataManager(context: DailyWeatherContext) -> DailyWeatherDataManagerProtocol
}


protocol HourlyWeatherDataManagerProvider {

  func getHourlyWeatherDataManager(context: HourlyWeatherContext) -> HourlyWeatherDataManagerProtocol
}


protocol ServerAPIManagerProvider {

  var serverAPIManager: ServerAPIManagerProtocol { get }
}


protocol StorageManagerProvider {

  var storageManager: StorageManagerProtocol { get }
}


class Injector: DailyWeatherDataManagerProvider, HourlyWeatherDataManagerProvider, ServerAPIManagerProvider, StorageManagerProvider {

  let serverAPIManager: ServerAPIManagerProtocol
  let storageManager: StorageManagerProtocol
  private var dailyWeatherDataManagers: [DailyWeatherContext: WeakWrapper<DailyWeatherDataManager>] = [:]
  private var hourlyWeatherDataManagers: [HourlyWeatherContext: WeakWrapper<HourlyWeatherDataManager>] = [:]

  init() {
    self.serverAPIManager = ServerAPIManager()
    self.storageManager = StorageManager()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  // MARK: - DailyWeatherDataManagerProvider

  func getDailyWeatherDataManager(context: DailyWeatherContext) -> DailyWeatherDataManagerProtocol {
    if let manager = dailyWeatherDataManagers[context]?.value { return manager }

    dailyWeatherDataManagers = dailyWeatherDataManagers.filter { $0.value.value != nil }
    let manager = DailyWeatherDataManager(context: context, serverAPIManager: serverAPIManager, storageManager: storageManager)
    dailyWeatherDataManagers[context] = WeakWrapper(manager)
    return manager
  }

  // MARK: - HourlyWeatherDataManagerProvider

  func getHourlyWeatherDataManager(context: HourlyWeatherContext) -> HourlyWeatherDataManagerProtocol {
    if let manager = hourlyWeatherDataManagers[context]?.value { return manager }

    hourlyWeatherDataManagers = hourlyWeatherDataManagers.filter { $0.value.value != nil }
    let manager = HourlyWeatherDataManager(context: context, serverAPIManager: serverAPIManager, storageManager: storageManager)
    hourlyWeatherDataManagers[context] = WeakWrapper(manager)
    return manager
  }
}


// MARK: - Private
private extension Injector {

  @objc
  func applicationWillEnterForeground() {
    dailyWeatherDataManagers.values.forEach { $0.value?.refetchDataIfNeeded() }
  }
}

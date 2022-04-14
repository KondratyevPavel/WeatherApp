//
//  Injector.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


protocol DailyWeatherDataManagerProvider {

  func getDailyWeatherDataManager(context: WeatherDataContext) -> DailyWeatherDataManagerProtocol
}


protocol ServerAPIManagerProvider {

  var serverAPIManager: ServerAPIManagerProtocol { get }
}


class Injector: DailyWeatherDataManagerProvider, ServerAPIManagerProvider {

  let serverAPIManager: ServerAPIManagerProtocol
  private var dailyWeatherDataManagers: [WeatherDataContext: WeakWrapper<DailyWeatherDataManager>] = [:]

  init() {
    self.serverAPIManager = ServerAPIManager()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  // MARK: - DailyWeatherDataManagerProvider

  func getDailyWeatherDataManager(context: WeatherDataContext) -> DailyWeatherDataManagerProtocol {
    if let manager = dailyWeatherDataManagers[context]?.value { return manager }

    dailyWeatherDataManagers = dailyWeatherDataManagers.filter { $0.value.value != nil }
    let manager = DailyWeatherDataManager(context: context, serverAPIManager: serverAPIManager)
    dailyWeatherDataManagers[context] = WeakWrapper(manager)
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

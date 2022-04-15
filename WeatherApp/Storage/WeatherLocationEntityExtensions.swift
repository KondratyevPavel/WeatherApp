//
//  WeatherLocationEntityExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import Foundation
import CoreData


extension WeatherLocationEntity {

  convenience init(context: NSManagedObjectContext, model: WeatherLocation) {
    self.init(context: context)

    self.latitude = model.latitude
    self.longitude = model.longitude
  }

  func makeModel() -> WeatherLocation {
    return WeatherLocation(
      latitude: latitude,
      longitude: longitude
    )
  }
}

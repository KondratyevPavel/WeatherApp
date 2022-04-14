//
//  WeakWrapper.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


struct WeakWrapper<T: AnyObject> {

  private(set) weak var value: T?

  init(_ value: T) {
    self.value = value
  }
}

//
//  UIntExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


extension UInt {

  init(object: AnyObject) {
    self = withUnsafeBytes(of: object) { pointer in
      return pointer.load(as: UInt.self)
    }
  }
}

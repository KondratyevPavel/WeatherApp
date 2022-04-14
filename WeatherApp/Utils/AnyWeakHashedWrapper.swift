//
//  AnyWeakHashedWrapper.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


struct AnyWeakHashedWrapper: Hashable {

  private let ptr: UInt
  private(set) weak var value: AnyObject?

  init(_ value: AnyObject) {
    self.value = value
    self.ptr = UInt(object: value)
  }

  static func ==(lhs: AnyWeakHashedWrapper, rhs: AnyWeakHashedWrapper) -> Bool {
    return lhs.ptr == rhs.ptr
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ptr)
  }
}

//
//  Listenable.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


protocol Listenable: AnyObject {

  func addListener(_ listener: AnyObject)
  func removeListener(_ listener: AnyObject)
}


protocol ListenableSupport: Listenable {

  var listeners: Set<AnyWeakHashedWrapper> { get set }
}


extension ListenableSupport {

  func addListener(_ listener: AnyObject) {
    listeners = listeners.filter { $0.value != nil }
    listeners.insert(AnyWeakHashedWrapper(listener))
  }

  func removeListener(_ listener: AnyObject) {
    listeners.remove(AnyWeakHashedWrapper(listener))
  }

  func enumerateListeners(_ block: (AnyObject) -> Void) {
    listeners
      .lazy
      .compactMap { $0.value }
      .forEach(block)
  }
}

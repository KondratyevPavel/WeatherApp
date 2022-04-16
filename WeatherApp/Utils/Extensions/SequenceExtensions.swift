//
//  SequenceExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 16.04.22.
//

import Foundation


extension Sequence {

  func makeDictionary<Key: Hashable>(_ keyBlock: (Element) -> Key) -> Dictionary<Key, Element> {
    return reduce(into: Dictionary<Key, Element>(), { $0[keyBlock($1)] = $1 })
  }
}

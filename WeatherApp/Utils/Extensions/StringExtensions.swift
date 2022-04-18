//
//  StringExtensions.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import UIKit


extension String {

  func size(font: UIFont) -> CGSize {
    return self.boundingRect(
      with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin],
      attributes: [.font: font],
      context: nil
    ).size
  }
}

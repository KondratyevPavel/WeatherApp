//
//  ViewFactory.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


enum ViewFactory {

  static func makeVerticalSeparator(width: CGFloat? = nil, color: UIColor? = nil) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = color ?? .systemGray
    view.widthAnchor.constraint(equalToConstant: width ?? LayoutConstants.px1).isActive = true
    return view
  }
}

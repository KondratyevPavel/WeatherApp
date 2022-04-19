//
//  AboutViewCoordinator.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 19.04.22.
//

import UIKit


protocol AboutViewCoordinatorDelegate: AnyObject {

  func dismiss(coordinator: AboutViewCoordinator)
}


class AboutViewCoordinator: AboutViewModelDelegate {

  typealias ViewModel = AboutViewModel
  typealias ViewController = AboutViewController

  private weak var viewController: ViewController?
  private weak var viewModel: ViewModel?
  private weak var delegate: AboutViewCoordinatorDelegate?

  static func build(delegate: AboutViewCoordinatorDelegate) -> ViewController {
    let coordinator = AboutViewCoordinator()
    let vm = ViewModel(coordinator: coordinator)
    let vc = ViewController(model: vm)
    coordinator.viewController = vc
    coordinator.viewModel = vm
    coordinator.delegate = delegate
    return vc
  }

  // MARK: - AboutViewModelDelegate

  func exitPressed() {
    delegate?.dismiss(coordinator: self)
  }

  func linkPressed(url: URL) {
    UIApplication.shared.open(url)
  }
}

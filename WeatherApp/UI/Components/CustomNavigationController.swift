//
//  CustomNavigationController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 19.04.22.
//

import UIKit


class CustomNavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)

    navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if
      isBeingPresented,
      let presentationController = presentationController,
      presentationController.delegate == nil
    {
      presentationController.delegate = self
    }
  }
  
  // MARK: - UIAdaptivePresentationControllerDelegate

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    (topViewController as? UIAdaptivePresentationControllerDelegate)?
      .presentationControllerDidDismiss?(presentationController)
  }
}

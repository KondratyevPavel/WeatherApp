//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: scene)
    self.window = window
    let viewController = WeatherOverviewViewCoordinator.build(injector: Injector())
    window.rootViewController = viewController
    window.makeKeyAndVisible()
  }
}

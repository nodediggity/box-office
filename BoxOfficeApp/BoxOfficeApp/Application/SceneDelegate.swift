//
//  SceneDelegate.swift
//  BoxOfficeApp
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UIViewController()
    window.rootViewController?.view.backgroundColor = .systemTeal

    self.window = window
    self.window?.makeKeyAndVisible()
  }
}


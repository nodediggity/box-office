//
//  SceneDelegate.swift
//  BoxOfficeApp
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNetworking
import BoxOfficeMedia
import BoxOfficeNowPlaying
import BoxOfficeNowPlayingiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  private lazy var config: AuthConfig = getConfig(fromPlist: "AuthConfig")

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UINavigationController(rootViewController: makeNowPlayingScene())

    self.window = window
    self.window?.makeKeyAndVisible()
  }
}

private extension SceneDelegate {

  func makeNowPlayingScene() -> NowPlayingViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteNowPlayingLoader(baseURL: URL(string: "https://api.themoviedb.org")!, client: authzClient)
    let imageLoader = RemoteImageDataLoader(client: client)

    let viewController = NowPlayingUIComposer.compose(loader: loader, imageLoader: imageLoader)
    return viewController
  }

}

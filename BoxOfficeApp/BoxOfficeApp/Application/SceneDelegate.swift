//
//  SceneDelegate.swift
//  BoxOfficeApp
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeCommoniOS
import BoxOfficeNetworking
import BoxOfficeMedia
import BoxOfficeNowPlaying
import BoxOfficeNowPlayingiOS
import BoxOfficeMovieDetails
import BoxOfficeMovieDetailsiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  private lazy var config: AuthConfig = getConfig(fromPlist: "AuthConfig")
  private lazy var navController = UINavigationController()

  private lazy var baseURL = URL(string: "https://api.themoviedb.org")!

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    UIFont.loadCustomFonts

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)

    navController.setViewControllers([makeNowPlayingScene()], animated: true)
    window.rootViewController = navController

    self.window = window
    self.window?.makeKeyAndVisible()
  }
}

private extension SceneDelegate {

  func makeNowPlayingScene() -> NowPlayingViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteNowPlayingLoader(baseURL: baseURL, client: authzClient)
    let imageLoader = RemoteImageDataLoader(client: client)

    let viewController = NowPlayingUIComposer.compose(loader: loader, imageLoader: imageLoader, onSelectCallback: { [weak self] movieID in
      guard let self = self else { return }
      let detailsViewController = self.makeMovieDetailScene(for: movieID)
      self.navController.pushViewController(detailsViewController, animated: true)
    })

    return viewController
  }

  func makeMovieDetailScene(for id: Int) -> MovieDetailsViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteMovieLoader(baseURL: baseURL, client: authzClient)
    let viewController = MovieDetailsUIComposer.compose(id: id, loader: loader, onPurchaseCallback: { })
    return viewController
  }
}

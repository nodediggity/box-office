//
//  NowPlayingUIComposer.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNowPlaying

public enum NowPlayingUIComposer {
  public static func compose(loader: NowPlayingLoader) -> NowPlayingViewController {

    let adapter = NowPlayingPresentationAdapter(loader: loader)
    let refreshController = NowPlayingRefreshController(delegate: adapter)
    let viewController = NowPlayingViewController(refreshController: refreshController)

    adapter.presenter = NowPlayingPresenter(
      view: WeakRefVirtualProxy(viewController),
      loadingView: WeakRefVirtualProxy(refreshController),
      errorView: WeakRefVirtualProxy(viewController)
    )

    return viewController
  }
}

extension WeakRefVirtualProxy: NowPlayingView where T: NowPlayingView {
  public func display(_ viewModel: NowPlayingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: NowPlayingLoadingView where T: NowPlayingLoadingView {
  public func display(_ viewModel: NowPlayingLoadingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: NowPlayingErrorView where T: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) {
    object?.display(viewModel)
  }
}

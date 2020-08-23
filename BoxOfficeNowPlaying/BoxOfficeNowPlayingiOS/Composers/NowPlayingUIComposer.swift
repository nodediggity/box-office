//
//  NowPlayingUIComposer.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMedia
import BoxOfficeNowPlaying

public enum NowPlayingUIComposer {
  public static func compose(loader: NowPlayingLoader, imageLoader: ImageDataLoader) -> NowPlayingViewController {

    let adapter = NowPlayingPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
    let refreshController = NowPlayingRefreshController(delegate: adapter)
    let viewController = NowPlayingViewController(refreshController: refreshController)

    adapter.presenter = NowPlayingPresenter(
      view: NowPlayingViewAdapter(controller: viewController, imageLoader: imageLoader),
      loadingView: WeakRefVirtualProxy(refreshController),
      errorView: WeakRefVirtualProxy(viewController)
    )

    return viewController
  }
}

// MARK:- WeakRefVirtualProxy

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

// MARK:- MainQueueDispatchDecorator

extension MainQueueDispatchDecorator: NowPlayingLoader where T == NowPlayingLoader {
  public func execute(_ req: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
    decoratee.execute(req, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}

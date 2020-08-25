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
import BoxOfficeCommon

public enum NowPlayingUIComposer {
  public static func compose(loader: NowPlayingLoader, imageLoader: ImageDataLoader, onSelectCallback: @escaping (Int) -> Void) -> NowPlayingViewController {

    let adapter = NowPlayingPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
    let refreshController = NowPlayingRefreshController(delegate: adapter)
    let pagingController = NowPlayingPagingController(delegate: adapter)
    let viewController = NowPlayingViewController(refreshController: refreshController, pagingController: pagingController)

    adapter.presenter = NowPlayingPresenter(
      view: NowPlayingViewAdapter(controller: viewController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader), onSelectCallback: onSelectCallback),
      loadingView: WeakRefVirtualProxy(refreshController),
      errorView: WeakRefVirtualProxy(viewController),
      pagingView: WeakRefVirtualProxy(pagingController)
    )

    viewController.title = NowPlayingPresenter.title

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

extension WeakRefVirtualProxy: NowPlayingPagingView where T: NowPlayingPagingView {
  public func display(_ viewModel: NowPlayingPagingViewModel) {
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

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
  public func load(from imageURL: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
    decoratee.load(from: imageURL, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}


protocol NowPlayingPagingControllerDelegate {
  func didRequestPage(page: Int)
}

final class NowPlayingPagingController {

  private let delegate: NowPlayingPagingControllerDelegate

  private var isLoading = false
  private var pageNumber: Int = 1
  private var isLast: Bool = false

  init(delegate: NowPlayingPagingControllerDelegate) {
    self.delegate = delegate
  }

  func load() {
    guard !isLoading && !isLast else { return }
    isLoading = true
    delegate.didRequestPage(page: pageNumber + 1)
  }

}

extension NowPlayingPagingController: NowPlayingPagingView {
  func display(_ viewModel: NowPlayingPagingViewModel) {
    isLoading = viewModel.isLoading
    pageNumber = viewModel.pageNumber
    isLast = viewModel.isLast
  }
}

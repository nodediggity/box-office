//
//  NowPlayingPresenter.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public protocol NowPlayingLoadingView {
  func display(_ viewModel: NowPlayingLoadingViewModel)
}

public protocol NowPlayingErrorView {
  func display(_ viewModel: NowPlayingErrorViewModel)
}

public protocol NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel)
}

public protocol NowPlayingPagingView {
  func display(_ viewModel: NowPlayingPagingViewModel)
}

public class NowPlayingPresenter {

  public static var title: String {
    return "Now Playing"
  }

  private let view: NowPlayingView
  private let loadingView: NowPlayingLoadingView
  private let errorView: NowPlayingErrorView
  private let pagingView: NowPlayingPagingView

  public init(view: NowPlayingView, loadingView: NowPlayingLoadingView, errorView: NowPlayingErrorView, pagingView: NowPlayingPagingView) {
    self.view = view
    self.loadingView = loadingView
    self.errorView = errorView
    self.pagingView = pagingView
  }

  public func didStartLoading() {
    loadingView.display(.init(isLoading: true))
    errorView.display(.noError)
    pagingView.display(.init(isLoading: true, isLast: true, pageNumber: 0))
  }

  public func didFinishLoading(with feed: NowPlayingFeed) {
    loadingView.display(.init(isLoading: false))
    view.display(.init(pageNumber: feed.page, items: feed.items))
    pagingView.display(.init(isLoading: false, isLast: feed.page == feed.totalPages, pageNumber: feed.page))

  }

  public func didFinishLoading(with error: Error) {
    loadingView.display(.init(isLoading: false))
    errorView.display(.error(message: error.localizedDescription))
  }

}

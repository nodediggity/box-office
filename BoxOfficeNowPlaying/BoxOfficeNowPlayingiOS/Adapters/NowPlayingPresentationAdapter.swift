//
//  NowPlayingPresentationAdapter.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNowPlaying

final class NowPlayingPresentationAdapter {

  var presenter: NowPlayingPresenter?

  private let loader: NowPlayingLoader

  init(loader: NowPlayingLoader) {
    self.loader = loader
  }
}

extension NowPlayingPresentationAdapter: NowPlayingRefreshControllerDelegate {
  func didRequestLoad() {
    presenter?.didStartLoading()
    load(page: 1)
  }
}

extension NowPlayingPresentationAdapter: NowPlayingPagingControllerDelegate {
  func didRequestPage(page: Int) {
    load(page: page)
  }
}

private extension NowPlayingPresentationAdapter {
  func load(page: Int) {
    loader.execute(.init(page: page), completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
        case let .success(feed): self.presenter?.didFinishLoading(with: feed)
        case let .failure(error): self.presenter?.didFinishLoading(with: error)
      }
    })
  }
}

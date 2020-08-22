//
//  NowPlayingRefreshController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

protocol NowPlayingRefreshControllerDelegate {
  func didRequestLoad()
}

final class NowPlayingRefreshController: NSObject {

  private let delegate: NowPlayingRefreshControllerDelegate

  private(set) lazy var view = loadView()

  init(delegate: NowPlayingRefreshControllerDelegate) {
    self.delegate = delegate
  }

  @objc func load() {
    delegate.didRequestLoad()
  }

}

extension NowPlayingRefreshController: NowPlayingLoadingView {
  func display(_ viewModel: NowPlayingLoadingViewModel) {
    viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
  }
}

private extension NowPlayingRefreshController {
  func loadView() -> UIRefreshControl {
    let view = UIRefreshControl(frame: .zero)
    return view
  }
}


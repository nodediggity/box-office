//
//  NowPlayingRefreshController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

final class NowPlayingRefreshController: NSObject {

  var onRefresh: (([NowPlayingCard]) -> Void)?

  private let loader: NowPlayingLoader

  private(set) lazy var view = loadView()

  init(loader: NowPlayingLoader) {
    self.loader = loader
  }

  @objc func load() {
    view.beginRefreshing()
    loader.execute(PagedNowPlayingRequest(page: 1), completion: { [weak self] result in
      if let page = try? result.get() {
        self?.onRefresh?(page.items)
      }
      self?.view.endRefreshing()
    })
  }

}

private extension NowPlayingRefreshController {
  func loadView() -> UIRefreshControl {
    let view = UIRefreshControl(frame: .zero)
    return view
  }
}


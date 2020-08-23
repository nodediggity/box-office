//
//  NowPlayingViewAdapter.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMedia
import BoxOfficeNowPlaying

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }

}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    controller?.items = viewModel.items.map(makeCellController(for:))
  }
}

private extension NowPlayingViewAdapter {
  func makeCellController(for model: NowPlayingCard) -> NowPlayingCardCellController {
    return NowPlayingCardCellController()
  }
}

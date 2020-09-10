//
//  NowPlayingCardCellController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNowPlaying

protocol NowPlayingPagingControllerDelegate {
  func didRequestPage(page: Int)
}

final class NowPlayingPagingController {

  private let delegate: NowPlayingPagingControllerDelegate
  private var viewModel: NowPlayingPagingViewModel?
  
  init(delegate: NowPlayingPagingControllerDelegate) {
    self.delegate = delegate
  }

  func load() {
    guard let viewModel = viewModel, let nextPage = viewModel.nextPage, !viewModel.isLoading else { return }

    delegate.didRequestPage(page: nextPage)
  }

}

extension NowPlayingPagingController: NowPlayingPagingView {
  func display(_ viewModel: NowPlayingPagingViewModel) {
    self.viewModel = viewModel
  }
}

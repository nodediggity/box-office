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

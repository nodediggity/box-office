//
//  NowPlayingPagingViewModel.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct NowPlayingPagingViewModel: Equatable {

  public let isLoading: Bool
  public let isLast: Bool
  public let pageNumber: Int

  public init(isLoading: Bool, isLast: Bool, pageNumber: Int) {
    self.isLoading = isLoading
    self.isLast = isLast
    self.pageNumber = pageNumber
  }
}

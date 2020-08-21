//
//  NowPlayingFeed.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct NowPlayingFeed: Equatable {
  public let items: [NowPlayingCard]
  public let page: Int
  public let totalPages: Int

  public init(items: [NowPlayingCard], page: Int, totalPages: Int) {
    self.items = items
    self.page = page
    self.totalPages = totalPages
  }
}

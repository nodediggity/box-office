//
//  NowPlayingCard.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct NowPlayingCard {
  public let id: Int
  public let title: String
  public let imagePath: String

  public init(id: Int, title: String, imagePath: String) {
    self.id = id
    self.title = title
    self.imagePath = imagePath
  }
}

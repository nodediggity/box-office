//
//  NowPlayingImageViewModel.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct NowPlayingImageViewModel<Image> {

  public let image: Image?
  public let title: String
  public let isLoading: Bool

  public init(image: Image?, title: String, isLoading: Bool) {
    self.image = image
    self.title = title
    self.isLoading = isLoading
  }
}

//
//  NowPlayingLoader.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct PagedNowPlayingRequest: Equatable {
  public let page: Int
  public let language: String

  public init(page: Int, language: String = "en-US") {
    self.page = page
    self.language = language
  }
}

public protocol NowPlayingLoader {
  typealias Result = Swift.Result<NowPlayingFeed, Error>
  func execute(_ req: PagedNowPlayingRequest, completion: @escaping (Result) -> Void)
}

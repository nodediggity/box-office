//
//  NowPlayingLoader.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

struct PagedNowPlayingRequest {
  let page: Int
  let language: String
}

protocol NowPlayingLoader {
  typealias Result = Swift.Result<[NowPlayingCard], Error>
  func execute(_ req: PagedNowPlayingRequest, completion: @escaping (Result) -> Void)
}

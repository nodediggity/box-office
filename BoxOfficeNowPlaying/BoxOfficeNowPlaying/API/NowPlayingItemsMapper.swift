//
//  NowPlayingItemsMapper.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

struct RemoteNowPlayingFeed: Decodable {

  struct RemoteNowPlayingCard: Decodable {
    let id: Int
    let original_title: String
    let poster_path: String
  }

  let results: [RemoteNowPlayingCard]
  let page: Int
  let total_pages: Int
}

final class NowPlayingItemsMapper {

  private static var OK_200: Int { return 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteNowPlayingFeed {
    guard response.statusCode == OK_200, let page = try? JSONDecoder().decode(RemoteNowPlayingFeed.self, from: data) else {
      throw RemoteNowPlayingLoader.Error.invalidResponse
    }

    return page
  }
}

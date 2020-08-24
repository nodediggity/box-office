//
//  RemoteMovieLoader.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNetworking

public final class RemoteMovieLoader: MovieLoader {

  public typealias Result = MovieLoader.Result

  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  private let baseURL: URL
  private let client: HTTPClient

  public init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  public func load(id: Int, completion: @escaping (Result) -> Void) {
    client.dispatch(URLRequest(url: enrich(baseURL, with: id)), completion: { [weak self] result in
      guard self != nil else { return }
      switch result {
        case let .success((data, response)): completion(RemoteMovieLoader.map(data, from: response))
        case .failure: completion(.failure(Error.connectivity))
      }
    })
  }
}

private extension RemoteMovieLoader {
  func enrich(_ url: URL, with movieID: Int) -> URL {
    return url
      .appendingPathComponent("3")
      .appendingPathComponent("movie")
      .appendingPathComponent("\(movieID)")
  }

  static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let value = try MovieMapper.map(data, from: response)
      return .success(value.asMovie)
    } catch {
      return .failure(error)
    }
  }
}

private extension RemoteMovie {
  var asMovie: Movie {
    return Movie(id: id, title: original_title, rating: vote_average, length: runtime, genres: genres.map { $0.name }, overview: overview, backdropImagePath: backdrop_path)
  }
}


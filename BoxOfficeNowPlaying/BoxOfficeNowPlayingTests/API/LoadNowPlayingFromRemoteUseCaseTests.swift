//
//  LoadNowPlayingFromRemoteUseCaseTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

class RemoteNowPlayingLoader {

  private let baseURL: URL
  private let client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy

  init(baseURL: URL, client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy) {
    self.baseURL = baseURL
    self.client = client
  }

  func execute(_ req: PagedNowPlayingRequest, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
    let request = URLRequest(url: enrich(baseURL, with: req))
    client.dispatch(request)
  }

}

private extension RemoteNowPlayingLoader {
  func enrich(_ url: URL, with req: PagedNowPlayingRequest) -> URL {

    let requestURL = url
      .appendingPathComponent("3")
      .appendingPathComponent("movie")
      .appendingPathComponent("now_playing")

    var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [
      URLQueryItem(name: "language", value: req.language),
      URLQueryItem(name: "page", value: "\(req.page)")
    ]
    return urlComponents?.url ?? requestURL
  }
}

class LoadNowPlayingFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_execute_requests_data_from_remote() {
    let request = PagedNowPlayingRequest(page: 1, language: "some-LANG")
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/now_playing?language=\(request.language)&page=\(request.page)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)
    sut.execute(request)

    XCTAssertEqual(client.requestedURLs, [expectedURL])
  }

  func test_execute_requests_data_from_remote_on_each_call() {
    let request = PagedNowPlayingRequest(page: 1, language: "some-LANG")
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/now_playing?language=\(request.language)&page=\(request.page)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.execute(request)
    sut.execute(request)

    XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
  }

}

extension LoadNowPlayingFromRemoteUseCaseTests {

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (RemoteNowPlayingLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteNowPlayingLoader(baseURL: baseURL ?? makeURL(), client: client)

    checkForMemoryLeaks(client, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  class HTTPClientSpy {

    var requestedURLs: [URL] {
      return messages.compactMap { $0.url }
    }

    private var messages: [URLRequest] = []

    func dispatch(_ request: URLRequest) {
      messages.append(request)
    }

  }

}

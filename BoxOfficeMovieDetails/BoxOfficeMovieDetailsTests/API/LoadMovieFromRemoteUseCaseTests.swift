//
//  LoadMovieFromRemoteUseCaseTests.swift
//  BoxOfficeMovieDetailsTests
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking

class RemoteMovieLoader {

  typealias Result = Swift.Result<Void, Error>

  enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  private let baseURL: URL
  private let client: HTTPClient

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  func load(id: Int, completion: @escaping (Result) -> Void) {
    client.dispatch(URLRequest(url: enrich(baseURL, with: id)), completion: { [weak self] result in
      switch result {
        case .success: completion(.failure(.invalidResponse))
        case .failure: completion(.failure(.connectivity))
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

}

class LoadMovieFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requests_data_from_remote() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL])
  }

  func test_load_requests_data_from_remote_on_each_call() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })
    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
  }

  func test_load_delivers_error_on_client_error() {
    let (sut, client) = makeSUT()
    let error = makeError()
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.completes(with: error)
    })
  }

  func test_execute_delivers_error_on_non_success_response() {
    let (sut, client) = makeSUT()
    let samples = [299, 300, 399, 400, 418, 499, 500]
    let data = makeData()
    samples.indices.forEach { index in
      expect(sut, toCompleteWith: failure(.invalidResponse), when: {
        client.completes(withStatusCode: samples[index], data: data, at: index)
      })
    }
  }
}

private extension LoadMovieFromRemoteUseCaseTests {
  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (RemoteMovieLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteMovieLoader(baseURL: baseURL ?? makeURL(), client: client)

    checkForMemoryLeaks(client, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load(id: 0, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.failure(receivedError as RemoteMovieLoader.Error), .failure(expectedError as RemoteMovieLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })
    action()
    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteMovieLoader.Error) -> RemoteMovieLoader.Result {
    return .failure(error)
  }
}

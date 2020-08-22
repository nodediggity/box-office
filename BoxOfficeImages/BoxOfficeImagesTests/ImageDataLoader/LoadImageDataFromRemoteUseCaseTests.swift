//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  BoxOfficeImagesTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking

class RemoteImageDataLoader {

  enum Error: Swift.Error {
    case connectivity
  }

  typealias Result = Swift.Result<Void, Error>

  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  func load(from imageURL: URL, completions: @escaping (Result) -> Void = { _ in }) {
    client.dispatch(URLRequest(url: imageURL), completion: { _ in
      completions(.failure(Error.connectivity))
    })
  }
}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requests_data_from_url() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL)

    XCTAssertEqual(client.requestedURLs, [requestURL])
  }

  func test_load_requests_data_from_remote_on_each_call() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL)
    sut.load(from: requestURL)

    XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
  }

  func test_execute_delivers_error_on_client_error() {
    let (sut, client) = makeSUT()
    let error = makeError()
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.completes(with: error)
    })
  }
}

private extension LoadImageDataFromRemoteUseCaseTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageDataLoader(client: client)
    checkForMemoryLeaks(sut, file: file, line: line)
    checkForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }

  func failure(_ error: RemoteImageDataLoader.Error) -> RemoteImageDataLoader.Result {
    return .failure(error)
  }


  func expect(_ sut: RemoteImageDataLoader, toCompleteWith expectedResult: RemoteImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    let imageURL = makeURL()

    sut.load(from: imageURL, completions: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.failure(receivedError as RemoteImageDataLoader.Error), .failure(expectedError as RemoteImageDataLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })
    action()
    wait(for: [exp], timeout: 1.0)
  }
}

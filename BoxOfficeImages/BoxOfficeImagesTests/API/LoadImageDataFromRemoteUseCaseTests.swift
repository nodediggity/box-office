//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  BoxOfficeImagesTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking
import BoxOfficeImages

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requests_data_from_url() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL) { _ in }

    XCTAssertEqual(client.requestedURLs, [requestURL])
  }

  func test_load_requests_data_from_remote_on_each_call() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL) { _ in }
    sut.load(from: requestURL) { _ in }

    XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
  }

  func test_load_delivers_error_on_client_error() {
    let (sut, client) = makeSUT()
    let error = makeError()
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.completes(with: error)
    })
  }

  func test_load_delivers_error_on_non_success_response() {
    let (sut, client) = makeSUT()
    let samples = [299, 300, 399, 400, 418, 499, 500]
    let data = makeData()
    samples.indices.forEach { index in
      expect(sut, toCompleteWith: failure(.invalidResponse), when: {
        client.completes(withStatusCode: samples[index], data: data, at: index)
      })
    }
  }

  func test_load_delivers_error_on_success_response_with_empty_data() {
    let (sut, client) = makeSUT()
    let emptyData = makeData(isEmpty: true)
    expect(sut, toCompleteWith: failure(.invalidResponse), when: {
      client.completes(withStatusCode: 200, data: emptyData)
    })
  }

  func test_delivers_success_on_success_response_with_non_empty_data() {
    let (sut, client) = makeSUT()
    let nonEmptyData = makeData()
    expect(sut, toCompleteWith: .success(nonEmptyData), when: {
      client.completes(withStatusCode: 200, data: nonEmptyData)
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

    sut.load(from: imageURL, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)): XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        case let (.failure(receivedError as RemoteImageDataLoader.Error), .failure(expectedError as RemoteImageDataLoader.Error)): XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default: XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })
    action()
    wait(for: [exp], timeout: 1.0)
  }
}

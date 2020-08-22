//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  BoxOfficeMediaTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking
import BoxOfficeMedia

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requests_data_from_url() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    _ = sut.load(from: requestURL) { _ in }

    XCTAssertEqual(client.requestedURLs, [requestURL])
  }

  func test_load_requests_data_from_remote_on_each_call() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    _ = sut.load(from: requestURL) { _ in }
    _ = sut.load(from: requestURL) { _ in }

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

  func test_cancel_pending_task_cancels_client_request() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    let task = sut.load(from: requestURL, completion: { _ in })
    XCTAssertTrue(client.cancelledURLs.isEmpty)

    task.cancel()
    XCTAssertEqual(client.cancelledURLs, [requestURL])
  }

  func test_load_does_not_deliver_data_after_cancelling_task() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()
    let imageData = makeData()

    var output: [Any] = []
    let task = sut.load(from: requestURL, completion: { output.append($0) })
    task.cancel()

    client.completes(withStatusCode: 418, data: imageData)
    client.completes(withStatusCode: 200, data: imageData)
    client.completes(with: makeError())

    XCTAssertTrue(output.isEmpty)
  }

  func test_does_not_invoke_completion_once_instance_has_been_deallocated() {
    let client = HTTPClientSpy()
    var sut: ImageDataLoader? = RemoteImageDataLoader(client: client)

    var output: Any? = nil
    let _ = sut?.load(from: makeURL(), completion: { output = $0 })
    sut = nil

    client.completes(withStatusCode: 200, data: makeData())
    XCTAssertNil(output)
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

    _ = sut.load(from: imageURL, completion: { receivedResult in
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

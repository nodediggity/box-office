//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  BoxOfficeAppTests
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking
import BoxOfficeApp

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

  func test_on_init_does_not_message_decoratee() {
    let (_, decoratee) = makeSUT(config: testConfig)
    XCTAssertTrue(decoratee.requestedURLs.isEmpty)
  }

  func test_on_dispatch_invokes_decoratee() {
    let (sut, decoratee) = makeSUT(config: testConfig)

    sut.dispatch(URLRequest(url: makeURL()), completion: { _ in })
    XCTAssertFalse(decoratee.requestedURLs.isEmpty)
  }

  func test_on_success_delivers_to_completion_handler() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let exp = expectation(description: "await completion")

    var output: (response: HTTPURLResponse, data: Data)? = nil
    sut.dispatch(.init(url: makeURL()), completion: { result in
      switch result {
        case let .success(body): output = body
        default: XCTFail("Expected success but got \(result) instead.")
      }
      exp.fulfill()
    })

    decoratee.completes(withStatusCode: 200, data: makeData())
    wait(for: [exp], timeout: 0.1)
    XCTAssertNotNil(output)
  }

  func test_on_failure_delivers_to_completion_handler() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let exp = expectation(description: "await completion")

    var output: Error? = nil
    sut.dispatch(.init(url: makeURL()), completion: { result in
      switch result {
        case let .failure(error): output = error
        default: XCTFail("Expected error but got \(result) instead.")
      }
      exp.fulfill()
    })

    decoratee.completes(with: makeError())
    wait(for: [exp], timeout: 0.1)
    XCTAssertNotNil(output)
  }

  func test_cancel_from_task_cancels_request() {
    let decoratee = HTTPClientSpy()
    let client = AuthenticatedHTTPClientDecorator(decoratee: decoratee, config: testConfig)

    var output: Any? = nil
    let task = client.dispatch(.init(url: makeURL()), completion: { result in
      output = result
    })

    task.cancel()
    XCTAssertNil(output)
  }

  func test_enriches_request_url_with_api_key() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let baseURL = makeURL()
    let expectedURL = makeURL("https://some-given-url.com?api_key=\(testConfig.secret)")

    sut.dispatch(URLRequest(url: baseURL), completion: { _ in })
    XCTAssertEqual(decoratee.requestedURLs, [expectedURL])
  }

}

private extension AuthenticatedHTTPClientDecoratorTests {

  var testConfig: AuthConfig {
    return .init(secret: "some-secret")
  }

  func makeSUT(config: AuthConfig, file: StaticString = #file, line: UInt = #line) -> (client: HTTPClient, decoratee: HTTPClientSpy) {
    let decoratee = HTTPClientSpy()
    let client = AuthenticatedHTTPClientDecorator(decoratee: decoratee, config: config)

    checkForMemoryLeaks(decoratee, file: file, line: line)
    checkForMemoryLeaks(client, file: file, line: line)

    return (client, decoratee)
  }


  class HTTPClientSpy: HTTPClient {

    typealias Result = HTTPClient.Result

    private struct Task: HTTPClientTask {
      let callback: () -> Void
      func cancel() { callback() }
    }

    private var messages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private(set) var cancelledURLs: [URL] = []

    var requestedURLs: [URL] {
      return messages.compactMap { $0.requests.url }
    }

    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
      messages.append((request, completion))
      return Task { [weak self] in self?.cancelledURLs.append(request.url!) }
    }

    func completes(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }

    func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
        )!
      messages[index].completion(.success((data, response)))
    }
  }
}

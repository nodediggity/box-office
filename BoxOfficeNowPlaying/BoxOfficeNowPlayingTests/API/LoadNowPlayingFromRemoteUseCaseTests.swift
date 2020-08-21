//
//  LoadNowPlayingFromRemoteUseCaseTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 21/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

class RemoteNowPlayingLoader {


}

class LoadNowPlayingFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

}

extension LoadNowPlayingFromRemoteUseCaseTests {

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteNowPlayingLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteNowPlayingLoader()

    checkForMemoryLeaks(client, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  class HTTPClientSpy {
    private(set) var requestedURLs: [URL] = []
  }

}

//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  BoxOfficeImagesTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

class RemoteImageDataLoader {

}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
}

private extension LoadImageDataFromRemoteUseCaseTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageDataLoader()
    checkForMemoryLeaks(sut, file: file, line: line)
    checkForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }
}

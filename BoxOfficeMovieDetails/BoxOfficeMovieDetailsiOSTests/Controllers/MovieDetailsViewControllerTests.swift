//
//  MovieDetailsViewControllerTests.swift
//  BoxOfficeMovieDetailsiOSTests
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

final class MovieDetailsViewController {

}

class MovieDetailsViewControllerTests: XCTestCase {

  func test_load_actions_request_details_from_loader() {
    let (_, loader) = makeSUT()
    XCTAssertTrue(loader.messages.isEmpty)
  }

}

private extension MovieDetailsViewControllerTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsViewController()

    checkForMemoryLeaks(loader, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  class LoaderSpy {
    private(set) var messages: [Any] = []
  }
}

//
//  MovieDetailsPresenterTests.swift
//  BoxOfficeMovieDetailsTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

class MovieDetailsPresenter {

}

class MovieDetailsPresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }
}

private extension MovieDetailsPresenterTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = MovieDetailsPresenter()
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy {
    private(set) var messages: [Any] = []
  }
}

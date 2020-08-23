//
//  NowPlayingImagePresenterTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

final class NowPlayingImagePresenter {

}

class NowPlayingImagePresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }
}

private extension NowPlayingImagePresenterTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingImagePresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingImagePresenter()
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy {

    private(set) var messages: [Any] = []
  }
}

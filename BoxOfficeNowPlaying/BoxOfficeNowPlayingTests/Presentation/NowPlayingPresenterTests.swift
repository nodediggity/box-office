//
//  NowPlayingPresenterTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

class NowPlayingPresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_did_start_loading_displays_no_errors_and_starts_loading() {
    let (sut, view) = makeSUT()

    sut.didStartLoading()
    XCTAssertEqual(view.messages, [.display(isLoading: true), .display(message: nil), .display(page: .init(isLoading: true, isLast: true, pageNumber: 0))])
  }

  func test_did_finish_loading_success_displays_feed_and_stops_loading() {
    let (sut, view) = makeSUT()
    let items = Array(0..<5).map { index in NowPlayingCard(id: index, title: "Card #\(index)", imagePath: "image-\(index).png") }
    let feed = NowPlayingFeed(items: items, page: 1, totalPages: 1)

    sut.didFinishLoading(with: feed)
    XCTAssertEqual(view.messages, [.display(isLoading: false), .display(items: items), .display(page: .init(isLoading: false, isLast: true, pageNumber: 1))])
  }

  func test_did_finish_loading_error_displays_error_and_stops_loading() {
    let (sut, view) = makeSUT()
    let errorDesc = "uh oh, could not update feed"
    let error = makeError(errorDesc)

    sut.didFinishLoading(with: error)
    XCTAssertEqual(view.messages, [.display(isLoading: false), .display(message: errorDesc)])
  }
}

private extension NowPlayingPresenterTests {

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingPresenter(view: view, loadingView: view, errorView: view, pagingView: view)
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy: NowPlayingLoadingView, NowPlayingErrorView, NowPlayingView, NowPlayingPagingView {

    enum Message: Equatable {
      case display(isLoading: Bool)
      case display(message: String?)
      case display(items: [NowPlayingCard])
      case display(page: NowPlayingPagingViewModel)
    }

    private(set) var messages: [Message] = []

    func display(_ viewModel: NowPlayingLoadingViewModel) {
      messages.append(.display(isLoading: viewModel.isLoading))
    }

    func display(_ viewModel: NowPlayingErrorViewModel) {
      messages.append(.display(message: viewModel.message))
    }

    func display(_ viewModel: NowPlayingViewModel) {
      messages.append(.display(items: viewModel.items))
    }

    func display(_ viewModel: NowPlayingPagingViewModel) {
      messages.append(.display(page: viewModel))
    }
  }

}

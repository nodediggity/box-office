//
//  NowPlayingPresenterTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

struct NowPlayingLoadingViewModel: Equatable {
  let isLoading: Bool
}

struct NowPlayingErrorViewModel: Equatable {
  let message: String?

  static var noError: NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: nil)
  }

  static func error(message: String) -> NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: message)
  }
}

struct NowPlayingViewModel: Equatable {
  let items: [NowPlayingCard]
}

protocol NowPlayingLoadingView {
  func display(_ viewModel: NowPlayingLoadingViewModel)
}

protocol NowPlayingErrorView {
  func display(_ viewModel: NowPlayingErrorViewModel)
}

protocol NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel)
}

class NowPlayingPresenter {

  private let view: NowPlayingView
  private let loadingView: NowPlayingLoadingView
  private let errorView: NowPlayingErrorView

  init(view: NowPlayingView, loadingView: NowPlayingLoadingView, errorView: NowPlayingErrorView) {
    self.view = view
    self.loadingView = loadingView
    self.errorView = errorView
  }

  func didStartLoading() {
    loadingView.display(.init(isLoading: true))
    errorView.display(.noError)
  }

  func didFinishLoading(with feed: NowPlayingFeed) {
    loadingView.display(.init(isLoading: false))
    view.display(.init(items: feed.items))
  }

}

class NowPlayingPresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_did_start_loading_displays_no_errors_and_starts_loading() {
    let (sut, view) = makeSUT()

    sut.didStartLoading()
    XCTAssertEqual(view.messages, [.display(isLoading: true), .display(message: nil)])
  }

  func test_did_finish_loading_success_displays_feed_and_stops_loading() {
    let (sut, view) = makeSUT()
    let items = Array(0..<5).map { index in NowPlayingCard(id: index, title: "Card #\(index)", imagePath: "image-\(index).png") }
    let feed = NowPlayingFeed(items: items, page: 1, totalPages: 1)

    sut.didFinishLoading(with: feed)
    XCTAssertEqual(view.messages, [.display(isLoading: false), .display(items: items)])
  }
}

private extension NowPlayingPresenterTests {

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingPresenter(view: view, loadingView: view, errorView: view)
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy: NowPlayingLoadingView, NowPlayingErrorView, NowPlayingView {

    enum Message: Equatable {
      case display(isLoading: Bool)
      case display(message: String?)
      case display(items: [NowPlayingCard])
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
  }

}

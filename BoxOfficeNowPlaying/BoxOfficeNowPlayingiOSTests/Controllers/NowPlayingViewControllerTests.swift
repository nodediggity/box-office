//
//  NowPlayingViewControllerTests.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying
import BoxOfficeNowPlayingiOS

class NowPlayingViewControllerTests: XCTestCase {

  func test_load_actions_request_now_playing_from_loader() {
    let (sut, loader) = makeSUT()
    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [.load(PagedNowPlayingRequest(page: 1))])

    sut.simulateUserRefresh()
    XCTAssertEqual(loader.messages, [
      .load(PagedNowPlayingRequest(page: 1)),
      .load(PagedNowPlayingRequest(page: 1))
    ])
  }

  func test_loading_indicator_is_visible_during_loading_state() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadFeedCompletes(with: .success(.init(items: [], page: 1, totalPages: 1)))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)

    sut.simulateUserRefresh()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadFeedCompletes(with: .failure(makeError()))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

  func test_load_completion_renders_successfully_loaded_now_playing_feed() {
    let (sut, loader) = makeSUT()
    let items = Array(0..<10).map { index in makeNowPlayingCard(id: index, title: "Card #\(index)") }
    let feedPage = makeNowPlayingFeed(items: items, pageNumber: 1, totalPages: 1)

    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [])

    loader.loadFeedCompletes(with: .success(feedPage))
    assertThat(sut, isRendering: items)
  }

}

private extension NowPlayingViewControllerTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingUIComposer.compose(loader: loader)

    checkForMemoryLeaks(loader, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  func makeNowPlayingFeed(items: [NowPlayingCard] = [], pageNumber: Int = 0, totalPages: Int = 1) -> NowPlayingFeed {
    return NowPlayingFeed(items: items, page: pageNumber, totalPages: totalPages)
  }

  func makeNowPlayingCard(id: Int, title: String? = nil, imagePath: String? = nil ) -> NowPlayingCard {
    return NowPlayingCard(id: id, title: title ?? UUID().uuidString, imagePath: imagePath ?? "\(UUID().uuidString).jpg")
  }

  func assertThat(_ sut: NowPlayingViewController, isRendering feed: [NowPlayingCard], file: StaticString = #file, line: UInt = #line) {
    guard sut.numberOfItems == feed.count else {
      return XCTFail("Expected \(feed.count) cards, got \(sut.numberOfItems) instead.", file: file, line: line)
    }
    feed.indices.forEach { index in
      assertThat(sut, hasViewConfiguredFor: feed[index], at: index)
    }
  }

  func assertThat(_ sut: NowPlayingViewController, hasViewConfiguredFor item: NowPlayingCard, at index: Int, file: StaticString = #file, line: UInt = #line) {
    let cell = sut.itemAt(index)
    guard let _ = cell as? NowPlayingCardFeedCell else {
      return XCTFail("Expected \(NowPlayingCardFeedCell.self) instance, got \(String(describing: cell)) instead", file: file, line: line)
    }
  }

  class LoaderSpy: NowPlayingLoader {

    enum Message: Equatable {
      case load(PagedNowPlayingRequest)
    }

    private(set) var messages: [Message] = []
    private var loadCompletions: [(NowPlayingLoader.Result) -> Void] = []

    func execute(_ req: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
      messages.append(.load(req))
      loadCompletions.append(completion)
    }

    func loadFeedCompletes(with result: NowPlayingLoader.Result, at index: Int = 0) {
      loadCompletions[index](result)
    }
  }
}

extension NowPlayingViewController {
  func simulateUserRefresh() {
    collectionView.refreshControl?.beginRefreshing()
    scrollViewDidEndDragging(collectionView, willDecelerate: true)
  }

  var loadingIndicatorIsVisible: Bool {
    return collectionView.refreshControl?.isRefreshing == true
  }

  var numberOfItems: Int {
    return collectionView.numberOfItems(inSection: 0)
  }

  func itemAt(_ item: Int, section: Int = 0) -> UICollectionViewCell? {
    let dataSource = collectionView.dataSource
    let indexPath = IndexPath(item: item, section: section)
    return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
  }
}

extension UIControl {
  func simulate(event: UIControl.Event) {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: event)?.forEach { (target as NSObject).perform(Selector($0)) }
    }
  }
}

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}

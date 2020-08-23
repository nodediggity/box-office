//
//  NowPlayingViewControllerTests.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeMedia
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

  func test_now_playing_card_loads_image_url_when_visible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero])

    sut.simulateItemVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero, expectedURLOne])
  }

  func test_now_playing_card_cancels_image_load_when_no_longer_visible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero])

    sut.simulateItemNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero, expectedURLOne])
  }

  func test_now_playing_card_shows_loading_indicator_when_image_is_loading() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))

    let viewOne = sut.simulateItemVisible(at: 0) as? NowPlayingCardFeedCell
    XCTAssertEqual(viewOne?.loadingIndicatorIsVisible, true)

    loader.completeImageLoading(with: makeData(), at: 0)
    XCTAssertEqual(viewOne?.loadingIndicatorIsVisible, false)

    let viewTwo = sut.simulateItemVisible(at: 1) as? NowPlayingCardFeedCell
    XCTAssertEqual(viewTwo?.loadingIndicatorIsVisible, true)

    loader.completeImageLoading(with: makeData(), at: 1)
    XCTAssertEqual(viewTwo?.loadingIndicatorIsVisible, false)
  }

  func test_now_playing_card_renders_image_from_remote() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))

    let imageZeroData = makeImageData(withColor: .purple)
    let viewZero = sut.simulateItemVisible(at: 0) as? NowPlayingCardFeedCell
    XCTAssertEqual(viewZero?.renderedImage, .none)

    loader.completeImageLoading(with: imageZeroData, at: 0)
    XCTAssertEqual(viewZero?.renderedImage, imageZeroData)

    let imageOneData = makeImageData(withColor: .darkGray)
    let viewOne = sut.simulateItemVisible(at: 1) as? NowPlayingCardFeedCell
    XCTAssertEqual(viewOne?.renderedImage, .none)

    loader.completeImageLoading(with: imageOneData, at: 1)
    XCTAssertEqual(viewOne?.renderedImage, imageOneData)
  }

  func test_now_playing_card_preloads_image_when_near_visible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemNearVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero])

    sut.simulateItemNearVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero, expectedURLOne])
  }

  func test_now_playing_card_cancels_preload_when_no_longer_near_visible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemNoLongerNearVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero])

    sut.simulateItemNoLongerNearVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero, expectedURLOne])
  }

  func test_now_playing_card_does_not_render_image_when_no_longer_visible() {
    let (sut, loader) = makeSUT()
    let item = makeNowPlayingCard(id: 0)
    let feedPage = makeNowPlayingFeed(items: [item], pageNumber: 1, totalPages: 1)

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))

    let view = sut.simulateItemNotVisible(at: 0) as? NowPlayingCardFeedCell
    loader.completeImageLoading(with: makeImageData(), at: 0)
    XCTAssertNil(view?.renderedImage)
  }

  func test_now_playing_loader_completes_from_background_to_main_thread() {
    let (sut, loader) = makeSUT()
    let item = makeNowPlayingCard(id: 0)
    let feedPage = makeNowPlayingFeed(items: [item], pageNumber: 1, totalPages: 1)
    sut.loadViewIfNeeded()

    let exp = expectation(description: "await background queue")
    DispatchQueue.global().async {
      loader.loadFeedCompletes(with: .success(feedPage))
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }

}

private extension NowPlayingViewControllerTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingUIComposer.compose(loader: loader, imageLoader: loader)

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

  class LoaderSpy: NowPlayingLoader, ImageDataLoader {

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

    private struct TaskSpy: ImageDataLoaderTask {
      let cancelCallback: () -> Void
      func cancel() {
        cancelCallback()
      }
    }

    private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()

    var loadedImageURLs: [URL] {
      return imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
      imageRequests.append((url, completion))
      return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      imageRequests[index].completion(.failure(error))
    }
  }

  func makeImageData(withColor color: UIColor = .systemTeal) -> Data {
    return makeImage(withColor: color).pngData()!
  }

  func makeImage(withColor color: UIColor = .systemTeal) -> UIImage {
    return UIImage.make(withColor: color)
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

  @discardableResult
  func simulateItemVisible(at index: Int) -> UICollectionViewCell? {
    return itemAt(index)
  }

  @discardableResult
  func simulateItemNotVisible(at index: Int) -> UICollectionViewCell? {
    let view = simulateItemVisible(at: index)

    let delegate = collectionView.delegate
    let indexPath = IndexPath(item: index, section: 0)
    delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)

    return view
  }

  func simulateItemNearVisible(at index: Int) {
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
  }

  func simulateItemNoLongerNearVisible(at index: Int) {
    simulateItemNearVisible(at: index)
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
  }
}

extension NowPlayingCardFeedCell {

  var renderedImage: Data? {
    return imageView.image?.pngData()
  }

  var loadingIndicatorIsVisible: Bool {
    return imageContainer.isShimmering
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

private extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()!
    context.setFillColor(color.cgColor)
    context.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}

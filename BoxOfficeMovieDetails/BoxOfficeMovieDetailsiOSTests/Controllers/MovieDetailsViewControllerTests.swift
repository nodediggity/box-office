//
//  MovieDetailsViewControllerTests.swift
//  BoxOfficeMovieDetailsiOSTests
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeMedia
import BoxOfficeMovieDetails
import BoxOfficeMovieDetailsiOS

class MovieDetailsViewControllerTests: XCTestCase {

  func test_load_actions_request_details_from_loader() {
    let movieID = 100
    let (sut, loader) = makeSUT(id: movieID)
    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [.load(movieID)])
  }

  func test_loading_indicator_is_visible_during_loading_state() {
    let (sut, loader) = makeSUT()
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadCompletes(with: .success(movie))
    loader.completeImageLoading()
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

  func test_on_load_success_renders_details() {
    let (sut, loader) = makeSUT()
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    loader.loadCompletes(with: .success(movie))
    loader.completeImageLoading()

    assertThat(sut, hasViewConfiguredFor: movie)
  }

  func test_on_tap_buy_ticket_notifies_observer() {
    var wasCalled = false
    let (sut, loader) = makeSUT(onBuyTicketSpy: { wasCalled = true })
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    loader.loadCompletes(with: .success(movie))

    sut.simulateBuyTicket()
    XCTAssertTrue(wasCalled)
  }

  func test_movie_loader_completes_from_background_to_main_thread() {
    let (sut, loader) = makeSUT()
    let movie = makeMovie()
    sut.loadViewIfNeeded()

    let exp = expectation(description: "await background queue")
    DispatchQueue.global().async {
      loader.loadCompletes(with: .success(movie))
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }

}

private extension MovieDetailsViewControllerTests {
  func makeSUT(id: Int = 0, onBuyTicketSpy: @escaping () -> Void = { }, file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsUIComposer.compose(id: id, loader: loader, imageLoader: loader, onPurchaseCallback: onBuyTicketSpy)

    checkForMemoryLeaks(loader, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  func makeMovie() -> Movie {
    return Movie(
      id: 1,
      title: "Any Movie",
      rating: 8.2,
      length: 130,
      genres: ["action"],
      overview: "An action movie",
      backdropImagePath: "some-action-movie-background.png"
    )
  }

  func assertThat(_ sut: MovieDetailsViewController, hasViewConfiguredFor item: Movie, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(sut.titleText, item.title, file: file, line: line)
    XCTAssertEqual(sut.metaText, "2 hr, 10 min | Action", file: file, line: line)
    XCTAssertEqual(sut.overviewText, item.overview, file: file, line: line)
  }

  class LoaderSpy: MovieLoader, ImageDataLoader {

    enum Message: Equatable {
      case load(Int)
    }

    private(set) var messages: [Message] = []

    typealias Result = MovieLoader.Result

    private var loadCompletions: [(Result) -> Void] = []
    func load(id: Int, completion: @escaping (Result) -> Void) {
      messages.append(.load(id))
      loadCompletions.append(completion)
    }

    func loadCompletes(with result: Result, at index: Int = 0) {
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
}

extension MovieDetailsViewController {

  var loadingIndicatorIsVisible: Bool {
    return customView.loadingIndicator.isAnimating
  }

  var titleText: String? {
    return customView.titleLabel.text
  }

  var metaText: String? {
    return customView.metaLabel.text
  }

  var overviewText: String? {
    return customView.overviewLabel.text
  }

  func simulateBuyTicket() {
    customView.buyTicketButton.simulateTap()
  }
}

extension UIControl {
  func simulate(event: UIControl.Event) {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: event)?.forEach { (target as NSObject).perform(Selector($0)) }
    }
  }
}

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}

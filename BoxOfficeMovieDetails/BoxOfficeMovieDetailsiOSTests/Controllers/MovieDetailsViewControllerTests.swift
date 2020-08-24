//
//  MovieDetailsViewControllerTests.swift
//  BoxOfficeMovieDetailsiOSTests
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeMovieDetails

final class MovieDetailsViewController: UIViewController {

  private var id: Int?
  private var loader: MovieLoader?

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    loadingIndicator.startAnimating()
    loader?.load(id: id!, completion: { [weak self] _ in
      self?.loadingIndicator.stopAnimating()
    })
  }
}

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
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

}

private extension MovieDetailsViewControllerTests {
  func makeSUT(id: Int = 0, file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsViewController(id: id, loader: loader)

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

  class LoaderSpy: MovieLoader {

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

  }
}

extension MovieDetailsViewController {

  var loadingIndicatorIsVisible: Bool {
    return loadingIndicator.isAnimating
  }
}

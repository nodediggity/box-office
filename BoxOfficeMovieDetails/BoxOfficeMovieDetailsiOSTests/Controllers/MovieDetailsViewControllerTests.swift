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

  private(set) public var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var metaLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var overviewLabel: UILabel = {
    let view = UILabel(frame: .zero)
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
    loader?.load(id: id!, completion: { [weak self] result in

      if let movie = try? result.get() {
        self?.titleLabel.text = movie.title

        let runTime = Double(movie.length * 60).asString(style: .short)
        let genres = movie.genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        self?.metaLabel.text = "\(runTime) | \(genres)"
        self?.overviewLabel.text = movie.overview
      }

      self?.loadingIndicator.stopAnimating()
    })
  }
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
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

  func test_on_load_success_renders_details() {
    let (sut, loader) = makeSUT()
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    loader.loadCompletes(with: .success(movie))

    assertThat(sut, hasViewConfiguredFor: movie)
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

  func assertThat(_ sut: MovieDetailsViewController, hasViewConfiguredFor item: Movie, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(sut.titleText, item.title, file: file, line: line)
    XCTAssertEqual(sut.metaText, "2 hr, 10 min | Action", file: file, line: line)
    XCTAssertEqual(sut.overviewText, item.overview, file: file, line: line)
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

  var titleText: String? {
    return titleLabel.text
  }

  var metaText: String? {
    return metaLabel.text
  }

  var overviewText: String? {
    return overviewLabel.text
  }
}

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

  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    loader?.load(id: id!, completion: { _ in })
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

}

private extension MovieDetailsViewControllerTests {
  func makeSUT(id: Int = 0, file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsViewController(id: id, loader: loader)

    checkForMemoryLeaks(loader, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  class LoaderSpy: MovieLoader {

    enum Message: Equatable {
      case load(Int)
    }

    private(set) var messages: [Message] = []

    typealias Result = MovieLoader.Result

    func load(id: Int, completion: @escaping (Result) -> Void) {
      messages.append(.load(id))
    }
  }
}

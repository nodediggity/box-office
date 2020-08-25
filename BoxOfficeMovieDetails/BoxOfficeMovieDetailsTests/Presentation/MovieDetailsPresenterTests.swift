//
//  MovieDetailsPresenterTests.swift
//  BoxOfficeMovieDetailsTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

struct MovieDetailsViewModel<Image> {

  let image: Image?
  let title: String?
  let meta: String?
  let overview: String?

  let isLoading: Bool
  let error: String?

  static var showLoading: MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: true, error: nil)
  }

  static func showError(message: String?) -> MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: false, error: message)
  }
}

protocol MovieDetailsView {
  associatedtype Image
  func display(_ model: MovieDetailsViewModel<Image>)
}


class MovieDetailsPresenter<View: MovieDetailsView, Image> where View.Image == Image {

  private let view: View
  private let imageTransformer: (Data) -> Image?

  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  func didStartLoading() {
    view.display(.showLoading)
  }

  func didFinishLoading(with error: Error) {
    view.display(.showError(message: error.localizedDescription))
  }
}

class MovieDetailsPresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_on_start_loading_hides_error_and_starts_loading_state() {
    let (sut, view) = makeSUT()

    sut.didStartLoading()

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, true)
    XCTAssertNil(message?.title)
    XCTAssertNil(message?.meta)
    XCTAssertNil(message?.overview)
    XCTAssertNil(message?.error)
    XCTAssertNil(message?.image)
  }

  func test_on_load_movie_error_sets_message_and_stops_loading() {
    let (sut, view) = makeSUT()
    let error = makeError("uh oh, could not find movie")

    sut.didFinishLoading(with: error)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertNil(message?.title)
    XCTAssertNil(message?.meta)
    XCTAssertNil(message?.overview)
    XCTAssertEqual(message?.error, error.localizedDescription)
    XCTAssertNil(message?.image)
  }
}

private extension MovieDetailsPresenterTests {
  func makeSUT(imageTransformer: @escaping (Data) -> SomeImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsPresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = MovieDetailsPresenter<ViewSpy, SomeImage>(view: view, imageTransformer: imageTransformer)
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  struct SomeImage: Equatable { }

  class ViewSpy: MovieDetailsView {

    private(set) var messages: [MovieDetailsViewModel<SomeImage>] = []

    func display(_ model: MovieDetailsViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}

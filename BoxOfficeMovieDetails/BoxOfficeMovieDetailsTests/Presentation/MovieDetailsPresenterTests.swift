//
//  MovieDetailsPresenterTests.swift
//  BoxOfficeMovieDetailsTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeMovieDetails

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

  func didFinishLoadingImageData(with error: Error, for movie: Movie) {
    view.display(MovieDetailsViewModel<Image>(
      image: nil,
      title: movie.title,
      meta: makeMovieMeta(length: movie.length, genres: movie.genres),
      overview: movie.overview,
      isLoading: false,
      error: nil
      )
    )
  }

  func didFinishLoadingImageData(with data: Data, for movie: Movie) {
    view.display(MovieDetailsViewModel<Image>(
      image: imageTransformer(data),
      title: movie.title,
      meta: makeMovieMeta(length: movie.length, genres: movie.genres),
      overview: movie.overview,
      isLoading: false,
      error: nil
      )
    )
  }
}

private extension MovieDetailsPresenter {
  func makeMovieMeta(length: CGFloat, genres: [String]) -> String {
    let runTime = Double(length * 60).asString(style: .short)
    let genres = genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
    return "\(runTime) | \(genres)"
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

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
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

  func test_on_load_movie_success_with_failed_image_download_renders_details_and_stops_loading() {
    let (sut, view) = makeSUT()
    let movie = makeMovie()
    let error = makeError("uh oh, could not find image for movie")

    sut.didFinishLoadingImageData(with: error, for: movie)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, movie.title)
    XCTAssertEqual(message?.meta, "2 hr, 19 min | Action, Romance")
    XCTAssertEqual(message?.overview, movie.overview)
    XCTAssertNil(message?.image)
    XCTAssertNil(message?.error)
  }

  func test_on_load_movie_and_image_success_displays_image_on_successful_transformation() {
    let transformedData = SomeImage()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
    let movie = makeMovie()

    sut.didFinishLoadingImageData(with: makeData(), for: movie)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, movie.title)
    XCTAssertEqual(message?.meta, "2 hr, 19 min | Action, Romance")
    XCTAssertEqual(message?.overview, movie.overview)
    XCTAssertEqual(message?.image, transformedData)
    XCTAssertNil(message?.error)
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

  func makeMovie() -> Movie {
    return Movie(id: 1, title: "A movie", rating: 8.4, length: 139, genres: ["Action", "Romance"], overview: "A romantic action movie", backdropImagePath: "any.png")
  }

  struct SomeImage: Equatable { }

  class ViewSpy: MovieDetailsView {

    private(set) var messages: [MovieDetailsViewModel<SomeImage>] = []

    func display(_ model: MovieDetailsViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}

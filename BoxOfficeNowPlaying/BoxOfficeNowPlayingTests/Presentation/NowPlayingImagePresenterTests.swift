//
//  NowPlayingImagePresenterTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

struct NowPlayingImageViewModel<Image> {
  let image: Image?
  let title: String
  let isLoading: Bool
}

protocol NowPlayingImageView {
  associatedtype Image
  func display(_ model: NowPlayingImageViewModel<Image>)
}

final class NowPlayingImagePresenter<View: NowPlayingImageView, Image> where View.Image == Image {

  private let view: View
  private let imageTransformer: (Data) -> Image?

  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  func didStartLoadingImageData(for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: true))
  }

  func didFinishLoadingImageData(with data: Data, for model: NowPlayingCard) {
    let image = imageTransformer(data)
    view.display(NowPlayingImageViewModel<Image>(image: image, title: model.title, isLoading: false))
  }

  func didFinishLoadingImageData(with error: Error, for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: false))
  }

}

class NowPlayingImagePresenterTests: XCTestCase {

  func test_on_init_does_not_message_view() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_did_start_loading_image_data_and_starts_loading_state() {
    let (sut, view) = makeSUT()
    let item = makeNowPlayingCard(id: 123)

    sut.didStartLoadingImageData(for: item)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.isLoading, true)
    XCTAssertEqual(message?.title, item.title)
    XCTAssertNil(message?.image)
  }

  func test_finish_loading_image_data_success_set_image_on_transform_success() {
    let transformedData = SomeImage()
    let item = makeNowPlayingCard(id: 123)
    let imageData = makeData()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

    sut.didFinishLoadingImageData(with: imageData, for: item)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, item.title)
    XCTAssertEqual(message?.image, transformedData)
  }

  func test_finish_loading_image_data_failure_ends_loading_state() {
    let (sut, view) = makeSUT()
    let item = makeNowPlayingCard(id: 123)
    let error = makeError()

    sut.didFinishLoadingImageData(with: error, for: item)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, item.title)
    XCTAssertNil(message?.image)
  }
}

private extension NowPlayingImagePresenterTests {

  func makeSUT(imageTransformer: @escaping (Data) -> SomeImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingImagePresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingImagePresenter(view: view, imageTransformer: imageTransformer)
    checkForMemoryLeaks(view, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  func makeNowPlayingCard(id: Int) -> NowPlayingCard {
    return NowPlayingCard(id: id, title: "Card #\(id)", imagePath: "image-for-card-\(id).png")
  }

  struct SomeImage: Equatable { }

  class ViewSpy: NowPlayingImageView {

    private(set) var messages: [NowPlayingImageViewModel<SomeImage>] = []

    func display(_ model: NowPlayingImageViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}

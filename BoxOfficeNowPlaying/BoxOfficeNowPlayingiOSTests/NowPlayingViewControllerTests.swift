//
//  NowPlayingViewControllerTests.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

final class NowPlayingViewController: UIViewController {

  private var loader: NowPlayingLoader?

  convenience init(loader: NowPlayingLoader) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    load()
  }
}

private extension NowPlayingViewController {
  func load() {
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { _ in })
  }
}

class NowPlayingViewControllerTests: XCTestCase {

  func test_load_actions_request_now_playing_from_loader() {
    let (sut, loader) = makeSUT()
    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [.load(PagedNowPlayingRequest(page: 1))])

  }

}

private extension NowPlayingViewControllerTests {
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingViewController(loader: loader)

    checkForMemoryLeaks(loader, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  class LoaderSpy: NowPlayingLoader {

    enum Message: Equatable {
      case load(PagedNowPlayingRequest)
    }

    private(set) var messages: [Message] = []

    func execute(_ req: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
      messages.append(.load(req))
    }
  }
}

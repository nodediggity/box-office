//
//  WeakRefVirtualProxyTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest

final class WeakRefVirtualProxy<T: AnyObject> {

  private(set) weak var object: T?

  init(_ object: T) {
    self.object = object
  }
}

class WeakRefVirtualProxyTests: XCTestCase {

  func test_reference_is_set_for_object() {
    let objectStub = ObjectStub()
    let sut = WeakRefVirtualProxy(objectStub)

    XCTAssertEqual(ObjectIdentifier(sut.object!), ObjectIdentifier(objectStub))
  }

}

private extension WeakRefVirtualProxyTests {
  class ObjectStub { }
}

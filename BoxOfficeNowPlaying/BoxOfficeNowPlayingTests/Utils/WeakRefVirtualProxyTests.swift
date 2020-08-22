//
//  WeakRefVirtualProxyTests.swift
//  BoxOfficeNowPlayingTests
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNowPlaying

class WeakRefVirtualProxyTests: XCTestCase {

  func test_reference_is_set_for_object() {
    let objectStub = ObjectStub()
    let sut = WeakRefVirtualProxy(objectStub)

    XCTAssertEqual(ObjectIdentifier(sut.object!), ObjectIdentifier(objectStub))
  }

  func test_reference_for_object_is_weak() {
    var objectStub: ObjectStub? = ObjectStub()
    let sut = WeakRefVirtualProxy(objectStub!)

    objectStub = nil
    XCTAssertNil(sut.object)
  }
}

private extension WeakRefVirtualProxyTests {
  class ObjectStub { }
}

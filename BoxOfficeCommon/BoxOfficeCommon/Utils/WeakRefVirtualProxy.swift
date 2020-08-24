//
//  WeakRefVirtualProxy.swift
//  BoxOfficeCommon
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public final class WeakRefVirtualProxy<T: AnyObject> {

  private(set) public weak var object: T?

  public init(_ object: T) {
    self.object = object
  }
}


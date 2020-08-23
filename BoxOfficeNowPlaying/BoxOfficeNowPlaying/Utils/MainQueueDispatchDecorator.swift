//
//  MainQueueDispatchDecorator.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public final class MainQueueDispatchDecorator<T> {

  private(set) public var decoratee: T

  public init(decoratee: T) {
    self.decoratee = decoratee
  }

  public func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }

    completion()
  }
}

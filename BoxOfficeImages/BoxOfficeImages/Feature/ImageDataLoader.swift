//
//  ImageDataLoader.swift
//  BoxOfficeImages
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public protocol ImageDataLoaderTask {
  func cancel()
}

public protocol ImageDataLoader {
  typealias Result = Swift.Result<Data, Error>

  func load(from imageURL: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

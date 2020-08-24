//
//  MovieLoader.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public protocol MovieLoader {
  typealias Result = Swift.Result<Movie, Error>
  func load(id: Int, completion: @escaping (Result) -> Void)
}

//
//  Movie.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

struct Movie {
  let id: String
  let title: String
  let rating: Int
  let runTime: Int
  let genres: [String]
  let overview: String
  let backdropImagePath: String
}

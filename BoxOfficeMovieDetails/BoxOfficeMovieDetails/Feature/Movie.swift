//
//  Movie.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Movie: Equatable {
  public let id: Int
  public let title: String
  public let rating: CGFloat
  public let length: CGFloat
  public let genres: [String]
  public let overview: String
  public let backdropImagePath: String

  public init(id: Int, title: String, rating: CGFloat, length: CGFloat, genres: [String], overview: String, backdropImagePath: String) {
    self.id = id
    self.title = title
    self.rating = rating
    self.length = length
    self.genres = genres
    self.overview = overview
    self.backdropImagePath = backdropImagePath
  }
}

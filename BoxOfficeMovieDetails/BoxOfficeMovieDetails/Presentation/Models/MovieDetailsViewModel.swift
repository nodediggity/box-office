//
//  MovieDetailsViewModel.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct MovieDetailsViewModel<Image> {

  public let image: Image?
  public let title: String?
  public let meta: String?
  public let overview: String?

  public let isLoading: Bool
  public let error: String?

  public init(image: Image?, title: String?, meta: String?, overview: String?, isLoading: Bool, error: String?) {
    self.image = image
    self.title = title
    self.meta = meta
    self.overview = overview
    self.isLoading = isLoading
    self.error = error
  }

  public static var showLoading: MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: true, error: nil)
  }

  public static func showError(message: String?) -> MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: false, error: message)
  }
}

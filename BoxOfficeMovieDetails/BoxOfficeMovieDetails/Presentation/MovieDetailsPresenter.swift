//
//  MovieDetailsPresenter.swift
//  BoxOfficeMovieDetails
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol MovieDetailsView {
  associatedtype Image
  func display(_ model: MovieDetailsViewModel<Image>)
}

public final class MovieDetailsPresenter<View: MovieDetailsView, Image> where View.Image == Image {

  private let view: View
  private let imageTransformer: (Data) -> Image?

  public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  public func didStartLoading() {
    view.display(.showLoading)
  }

  public func didFinishLoading(with error: Error) {
    view.display(.showError(message: error.localizedDescription))
  }

  public func didFinishLoadingImageData(with error: Error, for movie: Movie) {
    view.display(MovieDetailsViewModel<Image>(
      image: nil,
      title: movie.title,
      meta: makeMovieMeta(length: movie.length, genres: movie.genres),
      overview: movie.overview,
      isLoading: false,
      error: nil
      )
    )
  }

  public func didFinishLoadingImageData(with data: Data, for movie: Movie) {
    view.display(MovieDetailsViewModel<Image>(
      image: imageTransformer(data),
      title: movie.title,
      meta: makeMovieMeta(length: movie.length, genres: movie.genres),
      overview: movie.overview,
      isLoading: false,
      error: nil
      )
    )
  }
}

private extension MovieDetailsPresenter {
  func makeMovieMeta(length: CGFloat, genres: [String]) -> String {
    let runTime = Double(length * 60).asString(style: .short)
    let genres = genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
    return "\(runTime) | \(genres)"
  }
}

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}


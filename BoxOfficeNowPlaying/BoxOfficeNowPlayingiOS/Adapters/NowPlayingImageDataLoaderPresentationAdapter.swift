//
//  NowPlayingImageDataLoaderPresentationAdapter.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMedia
import BoxOfficeNowPlaying

final class NowPlayingImageDataLoaderPresentationAdapter<View: NowPlayingImageView, Image>: NowPlayingCardCellControllerDelegate where View.Image == Image {

  var presenter: NowPlayingImagePresenter<View, Image>?

  private let baseURL: URL
  private let model: NowPlayingCard
  private let imageLoader: ImageDataLoader

  init(baseURL: URL, model: NowPlayingCard, imageLoader: ImageDataLoader) {
    self.baseURL = baseURL
    self.model = model
    self.imageLoader = imageLoader
  }

  func didRequestLoadImage() {
    presenter?.didStartLoadingImageData(for: model)
    _ = imageLoader.load(from: makeImageURL(withPath: model.imagePath), completion: { _ in })
  }
}

private extension NowPlayingImageDataLoaderPresentationAdapter {
  func makeImageURL(withPath path: String) -> URL {
    return baseURL.appendingPathComponent(path)
  }
}

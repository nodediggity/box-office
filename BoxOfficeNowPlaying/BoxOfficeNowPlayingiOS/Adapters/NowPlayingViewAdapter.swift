//
//  NowPlayingViewAdapter.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeMedia
import BoxOfficeNowPlaying

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }

}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    controller?.items = viewModel.items.map(makeCellController(for:))
  }
}

private extension NowPlayingViewAdapter {
  func makeCellController(for model: NowPlayingCard) -> NowPlayingCardCellController {
    let adapter = NowPlayingImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NowPlayingCardCellController>, UIImage>(
      baseURL: URL(string: "https://image.tmdb.org/t/p/w500/")!, // TODO: Create URL factory
      model: model,
      imageLoader: imageLoader
    )
    
    let view = NowPlayingCardCellController(delegate: adapter)
    adapter.presenter = NowPlayingImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)

    return view
  }
}

extension WeakRefVirtualProxy: NowPlayingImageView where T: NowPlayingImageView, T.Image == UIImage {
  public func display(_ model: NowPlayingImageViewModel<UIImage>) {
    object?.display(model)
  }
}

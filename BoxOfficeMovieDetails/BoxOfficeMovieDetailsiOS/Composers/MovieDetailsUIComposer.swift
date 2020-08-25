//
//  MovieDetailsUIComposer.swift
//  BoxOfficeMovieDetailsiOS
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeMedia
import BoxOfficeMovieDetails
import BoxOfficeCommon

public enum MovieDetailsUIComposer {
  public static func compose(id: Int, loader: MovieLoader, imageLoader: ImageDataLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {

    let adapter = MovieLoaderPresentationAdapter<WeakRefVirtualProxy<MovieDetailsViewController>, UIImage>(
      id: id,
      loader: MainQueueDispatchDecorator(decoratee: loader),
      imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
    )

    let viewController = MovieDetailsViewController(delegate: adapter)
    viewController.onBuyTicket = onPurchaseCallback

    adapter.presenter = MovieDetailsPresenter(view: WeakRefVirtualProxy(viewController), imageTransformer: UIImage.init)

    return viewController
  }
}

// MARK:- MainQueueDispatchDecorator
extension MainQueueDispatchDecorator: MovieLoader where T == MovieLoader {
  public func load(id: Int, completion: @escaping (MovieLoader.Result) -> Void) {
    decoratee.load(id: id, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
  public func load(from imageURL: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
    decoratee.load(from: imageURL, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}

// MARK:- WeakRefVirtualProxy
extension WeakRefVirtualProxy: MovieDetailsView where T: MovieDetailsView, T.Image == UIImage {
  public func display(_ model: MovieDetailsViewModel<UIImage>) {
    object?.display(model)
  }
}

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

final class MovieLoaderPresentationAdapter<View: MovieDetailsView, Image>: MovieDetailsViewControllerDelegate where View.Image == Image {

  var presenter: MovieDetailsPresenter<View, Image>?

  private let id: Int
  private let loader: MovieLoader
  private let imageLoader: ImageDataLoader

  private var task: ImageDataLoaderTask?

  init(id: Int, loader: MovieLoader, imageLoader: ImageDataLoader) {
    self.id = id
    self.loader = loader
    self.imageLoader = imageLoader
  }

  func didRequestLoad() {
    presenter?.didStartLoading()
    loader.load(id: id, completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
        case let .success(movie): self.loadImage(for: movie)
        case let .failure(error): self.presenter?.didFinishLoading(with: error)
      }
    })
  }
}

private extension MovieLoaderPresentationAdapter {
  func loadImage(for model: Movie) {
    task = imageLoader.load(from: makeImageURL(withPath: model.backdropImagePath), completion: { [weak self] result in
      guard let self = self else { return }
      switch result {
        case let .success(imageData): self.presenter?.didFinishLoadingImageData(with: imageData, for: model)
        case let .failure(error): self.presenter?.didFinishLoadingImageData(with: error, for: model)
      }
    })
  }

  func makeImageURL(withPath path: String) -> URL {
    return URL(string: "https://image.tmdb.org/t/p/w1280/")!.appendingPathComponent(path)
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

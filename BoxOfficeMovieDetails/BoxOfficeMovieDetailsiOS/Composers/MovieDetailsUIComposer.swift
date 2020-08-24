//
//  MovieDetailsUIComposer.swift
//  BoxOfficeMovieDetailsiOS
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMovieDetails
import BoxOfficeCommon

public enum MovieDetailsUIComposer {
  public static func compose(id: Int, loader: MovieLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {
    let viewController = MovieDetailsViewController(id: id, loader: MainQueueDispatchDecorator(decoratee: loader))
    viewController.onBuyTicket = onPurchaseCallback
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

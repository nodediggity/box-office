//
//  MovieDetailsUIComposer.swift
//  BoxOfficeMovieDetailsiOS
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMovieDetails

public enum MovieDetailsUIComposer {
  public static func compose(id: Int, loader: MovieLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {
    let viewController = MovieDetailsViewController(id: id, loader: loader)
    viewController.onBuyTicket = onPurchaseCallback
    return viewController
  }
}


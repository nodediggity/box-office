//
//  MovieDetailsViewController+Ext.swift
//  BoxOfficeMovieDetailsiOSTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeMovieDetailsiOS

extension MovieDetailsViewController {

  var loadingIndicatorIsVisible: Bool {
    return customView.loadingIndicator.isAnimating
  }

  var titleText: String? {
    return customView.titleLabel.text
  }

  var metaText: String? {
    return customView.metaLabel.text
  }

  var overviewText: String? {
    return customView.overviewLabel.text
  }

  func simulateBuyTicket() {
    customView.buyTicketButton.simulateTap()
  }

  var renderedImage: Data? {
    return customView.bakcgroundImageView.image?.pngData()
  }
}

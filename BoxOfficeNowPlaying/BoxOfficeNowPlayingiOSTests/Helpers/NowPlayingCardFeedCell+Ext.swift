//
//  NowPlayingCardFeedCell+Ext.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNowPlayingiOS

extension NowPlayingCardFeedCell {

  var renderedImage: Data? {
    return imageView.image?.pngData()
  }

  var loadingIndicatorIsVisible: Bool {
    return isShimmering
  }
}

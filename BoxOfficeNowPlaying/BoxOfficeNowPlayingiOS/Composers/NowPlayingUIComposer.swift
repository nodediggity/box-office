//
//  NowPlayingUIComposer.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation
import BoxOfficeNowPlaying

public enum NowPlayingUIComposer {
  public static func compose(loader: NowPlayingLoader) -> NowPlayingViewController {
    let refreshController = NowPlayingRefreshController(loader: loader)
    let viewController = NowPlayingViewController(refreshController: refreshController)
    return viewController
  }
}

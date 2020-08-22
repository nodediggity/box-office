//
//  NowPlayingErrorViewModel.swift
//  BoxOfficeNowPlaying
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct NowPlayingErrorViewModel: Equatable {
  public let message: String?

  public static var noError: NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: nil)
  }

  public static func error(message: String) -> NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: message)
  }
}

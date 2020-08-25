//
//  UIRefreshControl+Ext.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}

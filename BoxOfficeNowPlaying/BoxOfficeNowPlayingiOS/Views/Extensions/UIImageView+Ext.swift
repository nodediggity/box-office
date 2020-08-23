//
//  UIImageView+Ext.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage

    guard newImage != nil else { return }

    alpha = 0
    UIView.animate(withDuration: 0.25) {
      self.alpha = 1
    }
  }
}

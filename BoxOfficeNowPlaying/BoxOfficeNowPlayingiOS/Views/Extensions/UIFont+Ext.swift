//
//  UIFont+Ext.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

extension UIFont {

  public static let loadCustomFonts: () = {
    loadFontWith(name: "Montserrat-Regular")
    loadFontWith(name: "Montserrat-Medium")
    loadFontWith(name: "Montserrat-Bold")
  }()

  enum FontWeight {
    case regular
    case medium
    case bold
  }

  static func custom(_ weight: FontWeight, size: CGFloat) -> UIFont {
    switch weight {
      case .regular:
        return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
      case .medium:
        return UIFont(name: "Montserrat-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
      case .bold:
        return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
  }


}

private extension UIFont {

  private class Typography { }

  static func loadFontWith(name: String) {
    let frameworkBundle = Bundle(for: Typography.self)
    let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf")
    let fontData = NSData(contentsOfFile: pathForResourceString!)
    let dataProvider = CGDataProvider(data: fontData!)
    let fontRef = CGFont(dataProvider!)
    var errorRef: Unmanaged<CFError>? = nil

    if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
      NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
    }
  }
}

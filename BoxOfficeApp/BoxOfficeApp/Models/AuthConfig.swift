//
//  AuthConfig.swift
//  BoxOfficeApp
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

public struct AuthConfig: Decodable {
  public let secret: String

  public init(secret: String) {
    self.secret = secret
  }
}

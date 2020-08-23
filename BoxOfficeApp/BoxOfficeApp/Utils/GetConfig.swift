//
//  GetConfig.swift
//  BoxOfficeApp
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import Foundation

func getConfig<T: Decodable>(fromPlist resource: String) -> T {
  guard
    let path = Bundle.main.path(forResource: resource, ofType: "plist"),
    let xml = FileManager.default.contents(atPath: path),
    let config = try? PropertyListDecoder().decode(T.self, from: xml)
    else { fatalError("Expected to find \(resource).plist but got nil instead") }
  return config
}


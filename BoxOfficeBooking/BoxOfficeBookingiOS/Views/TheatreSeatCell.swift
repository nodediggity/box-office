//
//  TheatreSeatCell.swift
//  BoxOfficeBookingiOS
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

final class TheatreSeatCell: UICollectionViewCell {

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  required init?(coder: NSCoder) {
    return nil
  }

  override var isSelected: Bool {
    didSet { toggleSelectedUIState() }
  }
}

private extension TheatreSeatCell {

  func configureUI() {
    layer.cornerRadius = frame.width / 2
  }

  func toggleSelectedUIState() {
    backgroundColor = isSelected ? #colorLiteral(red: 0.9764705882, green: 0.8392156863, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
  }
}

//
//  NowPlayingCardFeedCell.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

public final class NowPlayingCardFeedCell: UICollectionViewCell {

  public let imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    view.clipsToBounds = true
    return view
  }()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  public required init?(coder: NSCoder) {
    return nil
  }
  
}

private extension NowPlayingCardFeedCell {
  func configureUI() {

    backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1960784314, blue: 0.2901960784, alpha: 1)
    contentView.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])

  }
}

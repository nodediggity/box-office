//
//  NowPlayingCardFeedCell.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

public final class NowPlayingCardFeedCell: UICollectionViewCell {

  public let imageContainer: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  public let imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
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
    backgroundColor = .darkGray
  }
}

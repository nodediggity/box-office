//
//  LoadMoreView.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Hai Phung on 5/22/21.
//  Copyright © 2021 Gordon Smith. All rights reserved.
//

import UIKit

public final class LoadMoreView: UICollectionReusableView {

  public lazy var activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
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

private extension LoadMoreView {
  func configureUI() {
    addSubview(activityIndicator)
  }
}

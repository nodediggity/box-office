//
//  NowPlayingCardCellController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

protocol NowPlayingCardCellControllerDelegate {
  func didRequestLoadImage()
  func didRequestCancelLoadImage()
}

final class NowPlayingCardCellController: Hashable {
  private let id: Int
  
  static func == (lhs: NowPlayingCardCellController, rhs: NowPlayingCardCellController) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  var didSelect: (() -> Void)?

  private var cell: NowPlayingCardFeedCell?

  private let delegate: NowPlayingCardCellControllerDelegate

  init(id: Int, delegate: NowPlayingCardCellControllerDelegate) {
    self.id = id
    self.delegate = delegate
  }

  func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
    delegate.didRequestLoadImage()
    return cell!
  }

  func cancelLoad() {
    delegate.didRequestCancelLoadImage()
    relaseCellForReuse()
  }

  func prefetch() {
    delegate.didRequestLoadImage()
  }

  func select() {
    didSelect?()
  }
}

private extension NowPlayingCardCellController {
  func relaseCellForReuse() {
    cell = nil
  }
}

extension NowPlayingCardCellController: NowPlayingImageView {
  func display(_ model: NowPlayingImageViewModel<UIImage>) {
    cell?.isShimmering = model.isLoading
    cell?.imageView.setImageAnimated(model.image)
  }
}

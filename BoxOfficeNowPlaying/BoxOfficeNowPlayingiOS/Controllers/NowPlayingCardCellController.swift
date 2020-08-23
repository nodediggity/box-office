//
//  NowPlayingCardCellController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 23/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

protocol NowPlayingCardCellControllerDelegate {
  func didRequestLoadImage()
  func didCancelLoadImage()
}

final class NowPlayingCardCellController {

  private var cell: NowPlayingCardFeedCell?

  func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
    return cell!
  }

  func cancel() {
    releaseCellForReuse()
  }

}

private extension NowPlayingCardCellController {
  private func releaseCellForReuse() {
    cell = nil
  }
}

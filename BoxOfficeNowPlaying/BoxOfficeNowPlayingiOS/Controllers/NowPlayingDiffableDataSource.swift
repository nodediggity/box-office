//
//  NowPlayingDiffableDataSource.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Hai Phung on 5/23/21.
//  Copyright © 2021 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

final class NowPlayingDiffableDataSource: UICollectionViewDiffableDataSource<Int, NowPlayingCardCellController> {
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoadMoreView", for: indexPath)
  }
}

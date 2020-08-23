//
//  NowPlayingViewController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

public final class NowPlayingViewController: UICollectionViewController {

  var items: [NowPlayingCardCellController] = [] {
    didSet { collectionView.reloadData() }
  }

  private var refreshController: NowPlayingRefreshController?

  convenience init(refreshController: NowPlayingRefreshController) {
    self.init(collectionViewLayout: UICollectionViewFlowLayout())
    self.refreshController = refreshController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.backgroundColor = .lightGray
    collectionView.prefetchDataSource = self
    collectionView.refreshControl = refreshController?.view
    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")

    refreshController?.load()
  }

  public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard collectionView.refreshControl?.isRefreshing == true else { return }
    refreshController?.load()
  }

  public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let controller = cellController(forItemAt: indexPath)
    return controller.view(in: collectionView, forItemAt: indexPath)
  }

  public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    removeCellController(forItemAt: indexPath)
  }
}

extension NowPlayingViewController: UICollectionViewDataSourcePrefetching {
  public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(prefetchCellController)
  }

  public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(removeCellController)
  }
}

private extension NowPlayingViewController {

  func cellController(forItemAt indexPath: IndexPath) -> NowPlayingCardCellController {
    let controller = items[indexPath.row]
    return controller
  }

  func removeCellController(forItemAt indexPath: IndexPath) {
    cellController(forItemAt: indexPath).cancelLoad()
  }

  func prefetchCellController(forItemAt indexPath: IndexPath) {
    cellController(forItemAt: indexPath).prefetch()
  }
}

extension NowPlayingViewController: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) { }
}

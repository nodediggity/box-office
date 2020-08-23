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
}

private extension NowPlayingViewController {
  func cellController(forItemAt indexPath: IndexPath) -> NowPlayingCardCellController {
    let controller = items[indexPath.row]
    return controller
  }
}

extension NowPlayingViewController: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) { }
}

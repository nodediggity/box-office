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

  private var refreshController: NowPlayingRefreshController?

  private var items: [NowPlayingCard] = [] {
    didSet { collectionView.reloadData() }
  }

  convenience init(refreshController: NowPlayingRefreshController) {
    self.init(collectionViewLayout: UICollectionViewFlowLayout())
    self.refreshController = refreshController

    refreshController.onRefresh = { [weak self] items in
      self?.items = items
    }
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as! NowPlayingCardFeedCell
    return cell
  }
}

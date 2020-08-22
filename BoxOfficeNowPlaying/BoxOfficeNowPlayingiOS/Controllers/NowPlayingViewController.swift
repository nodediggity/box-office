//
//  NowPlayingViewController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

public final class NowPlayingCardFeedCell: UICollectionViewCell { }

public final class NowPlayingViewController: UIViewController {

  public let refreshControl = UIRefreshControl(frame: .zero)
  private(set) public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")

    refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)

    collectionView.refreshControl = refreshControl
    return collectionView
  }()

  private var loader: NowPlayingLoader?

  private var items: [NowPlayingCard] = [] {
    didSet { collectionView.reloadData() }
  }

  public convenience init(loader: NowPlayingLoader) {
    self.init()
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    load()
  }
}

private extension NowPlayingViewController {
  @objc func load() {
    refreshControl.beginRefreshing()
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { [weak self] result in
      if let page = try? result.get() {
        self?.items = page.items
      }
      self?.refreshControl.endRefreshing()
    })
  }
}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.isRefreshing == true else { return }
    load()
  }
}

extension NowPlayingViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath)
    return cell
  }
}

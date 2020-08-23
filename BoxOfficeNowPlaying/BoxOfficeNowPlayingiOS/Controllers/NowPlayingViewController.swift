//
//  NowPlayingViewController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying

public final class NowPlayingViewController: UIViewController {

  var items: [NowPlayingCardCellController] = [] {
    didSet { collectionView.reloadData() }
  }

  private(set) public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createLayout(size: view.bounds.size))
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)
    collectionView.prefetchDataSource = self
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.refreshControl = refreshController?.view
    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
    return collectionView
  }()

  private var refreshController: NowPlayingRefreshController?

  convenience init(refreshController: NowPlayingRefreshController) {
    self.init(nibName: nil, bundle: nil)
    self.refreshController = refreshController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    navigationItem.title = "Now Playing"
    navigationController?.navigationBar.prefersLargeTitles = true

    navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1),
      NSAttributedString.Key.font: UIFont.custom(.bold, size: 34),
    ]

    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1),
      NSAttributedString.Key.font: UIFont.custom(.medium, size: 20)
    ]

    navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)


    refreshController?.load()
  }
}

extension NowPlayingViewController: UICollectionViewDelegate {

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard collectionView.refreshControl?.isRefreshing == true else { return }
    refreshController?.load()
  }

  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    removeCellController(forItemAt: indexPath)
  }
}

extension NowPlayingViewController: UICollectionViewDataSource {

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let controller = cellController(forItemAt: indexPath)
    return controller.view(in: collectionView, forItemAt: indexPath)
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

  private func createLayout(isLandscape: Bool = false, size: CGSize) -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnv) -> NSCollectionLayoutSection? in

      let leadingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
      let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
      leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

      let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
      let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
      trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

      let trailingLeftGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
        subitem: trailingItem, count: 2
      )

      let trailingRightGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
        subitem: trailingItem, count: 2
      )

      let fractionalHeight = isLandscape ? NSCollectionLayoutDimension.fractionalHeight(0.8) : NSCollectionLayoutDimension.fractionalHeight(0.4)
      let groupDimensionHeight: NSCollectionLayoutDimension = fractionalHeight

      let rightGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
        subitems: [leadingItem, trailingLeftGroup, trailingRightGroup]
      )

      let leftGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
        subitems: [trailingRightGroup, trailingLeftGroup, leadingItem]
      )

      let height = isLandscape ? size.height / 0.9 : size.height / 1.25
      let megaGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(height)),
        subitems: [rightGroup, leftGroup]
      )

      return NSCollectionLayoutSection(group: megaGroup)
    }
  }

}

extension NowPlayingViewController: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) { }
}

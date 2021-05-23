//
//  NowPlayingViewController.swift
//  BoxOfficeNowPlayingiOS
//
//  Created by Gordon Smith on 22/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlaying
import BoxOfficeCommoniOS

public final class NowPlayingViewController: UICollectionViewController {

  func set(_ newItems: [NowPlayingCardCellController]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, NowPlayingCardCellController>()
    snapshot.appendSections([0])
    snapshot.appendItems(newItems, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  func append(_ newItems: [NowPlayingCardCellController]) {
    var snapshot = dataSource.snapshot()
    snapshot.appendItems(newItems, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private lazy var dataSource: NowPlayingDiffableDataSource = {
    .init(collectionView: collectionView) { collectionView, indexPath, controller in
      controller.view(in: collectionView, forItemAt: indexPath)
    }
  }()

  private var refreshController: NowPlayingRefreshController?
  private var pagingController: NowPlayingPagingController?

  convenience init(refreshController: NowPlayingRefreshController, pagingController: NowPlayingPagingController) {
    self.init(collectionViewLayout: UICollectionViewFlowLayout())
    self.refreshController = refreshController
    self.pagingController = pagingController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureNavigation()
    refreshController?.load()
  }
}

extension NowPlayingViewController {

  public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard collectionView.refreshControl?.isRefreshing == true else { return }
    refreshController?.load()
  }
  
  public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    prefetchCellController(forItemAt: indexPath)
  }

  public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    removeCellController(forItemAt: indexPath)
  }

  public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cellController(forItemAt: indexPath)?.select()
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

  func configureUI() {
    collectionView.collectionViewLayout = createLayout(size: view.bounds.size)
    collectionView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)
    collectionView.prefetchDataSource = self
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.refreshControl = refreshController?.view
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
    collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoadMoreView")
  }

  func configureNavigation() {

    //navigationController?.navigationBar.prefersLargeTitles = true

    navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1),
      NSAttributedString.Key.font: UIFont.custom(.bold, size: 34),
    ]

    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1),
      NSAttributedString.Key.font: UIFont.custom(.medium, size: 20)
    ]

    navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)
  }

  func cellController(forItemAt indexPath: IndexPath) -> NowPlayingCardCellController? {
    let controller = dataSource.itemIdentifier(for: indexPath)
    return controller
  }

  func removeCellController(forItemAt indexPath: IndexPath) {
    cellController(forItemAt: indexPath)?.cancelLoad()
  }

  func prefetchCellController(forItemAt indexPath: IndexPath) {
    cellController(forItemAt: indexPath)?.prefetch()
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
      
      let primarySection = NSCollectionLayoutSection(group: megaGroup)
      let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
      primarySection.boundarySupplementaryItems = [footer]

      return primarySection
    }
  }

}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    guard section == 0 else { return .zero }
    return CGSize(width: collectionView.frame.width, height: 50.0)
  }
  
  public override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    guard elementKind == UICollectionView.elementKindSectionFooter else { return }
    pagingController?.load()
  }
}
extension NowPlayingViewController: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) { }
}

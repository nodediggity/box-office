//
//  NowPlayingViewController+Ext.swift
//  BoxOfficeNowPlayingiOSTests
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeNowPlayingiOS

extension NowPlayingViewController {
  func simulateUserRefresh() {
    collectionView.refreshControl?.beginRefreshing()
    scrollViewDidEndDragging(collectionView, willDecelerate: true)
  }

  var loadingIndicatorIsVisible: Bool {
    return collectionView.refreshControl?.isRefreshing == true
  }

  var numberOfItems: Int {
    return collectionView.numberOfItems(inSection: 0)
  }

  func itemAt(_ item: Int, section: Int = 0) -> UICollectionViewCell? {
    let dataSource = collectionView.dataSource
    let indexPath = IndexPath(item: item, section: section)
    return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
  }

  @discardableResult
  func simulateItemVisible(at index: Int) -> UICollectionViewCell? {
    return itemAt(index)
  }

  @discardableResult
  func simulateItemNotVisible(at index: Int) -> UICollectionViewCell? {
    let view = simulateItemVisible(at: index)

    let delegate = collectionView.delegate
    let indexPath = IndexPath(item: index, section: 0)
    delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)

    return view
  }

  func simulateItemNearVisible(at index: Int) {
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
  }

  func simulateItemNoLongerNearVisible(at index: Int) {
    simulateItemNearVisible(at: index)
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
  }

  func simulateSelectItem(at index: Int) {
    let delegate = collectionView.delegate
    let indexPath = IndexPath(item: index, section: 0)
    delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
  }

  func simulatePagingRequest() {
    collectionView.contentOffset.y = 1000
    scrollViewDidScroll(collectionView)
  }
}


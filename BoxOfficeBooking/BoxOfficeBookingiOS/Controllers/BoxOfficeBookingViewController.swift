//
//  BoxOfficeBookingViewController.swift
//  BoxOfficeBookingiOS
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeCommoniOS

public final class BoxOfficeBookingViewController: UIViewController {

  struct TheatreSeat {
    enum State {
      case empty
      case reserved
      case unavailable
    }

    let state: State
  }

  private var seats: [TheatreSeat] = [] {
    didSet { customView.collectionView.reloadData() }
  }

  private(set) public lazy var customView = view as! BoxOfficeBookingCustomView

  public override func loadView() {
    view = BoxOfficeBookingCustomView(frame: UIScreen.main.bounds)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    customView.collectionView.dataSource = self
    customView.collectionView.delegate = self

    seats = makeTheatreLayout()
    customView.checkoutButton.addTarget(self, action: #selector(onTapDismiss), for: .touchUpInside)
    customView.dismissButton.addTarget(self, action: #selector(onTapDismiss), for: .touchUpInside)
  }

}

extension BoxOfficeBookingViewController: UICollectionViewDataSource {

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return seats.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let seat = seats[indexPath.item]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! TheatreSeatCell
    switch seat.state {
      case .empty: cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      case .unavailable: cell.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1490196078, alpha: 1)
      case .reserved: cell.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1764705882, blue: 0.2117647059, alpha: 1)
    }

    if seat.state != .empty {
      cell.isUserInteractionEnabled = false
    }

    return cell
  }
}

extension BoxOfficeBookingViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: 44, height: 44)
  }
}

private extension BoxOfficeBookingViewController {
  func makeTheatreLayout() -> [TheatreSeat] {
    return Array(0..<48).map { index in
      guard ![0, 5, 42, 47].contains(index) else { return TheatreSeat(state: .unavailable) }
      return TheatreSeat(state: Bool.random() ? .reserved : .empty)
    }
  }

  @objc func onTapDismiss() {
    dismiss(animated: true)
  }
}

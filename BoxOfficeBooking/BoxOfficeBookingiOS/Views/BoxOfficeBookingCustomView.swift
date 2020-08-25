//
//  BoxOfficeBookingCustomView.swift
//  BoxOfficeBookingiOS
//
//  Created by Gordon Smith on 25/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit

public final class BoxOfficeBookingCustomView: UIView {

  private(set) lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .systemBackground
    collectionView.isScrollEnabled = false
    collectionView.allowsMultipleSelection = true
    collectionView.register(TheatreSeatCell.self, forCellWithReuseIdentifier: "CustomCell")
    collectionView.heightAnchor.constraint(equalToConstant: 340).isActive = true
    collectionView.widthAnchor.constraint(equalToConstant: 400).isActive = true
    return collectionView
  }()

  private let containerView: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1490196078, alpha: 1)
    view.clipsToBounds = true
    view.layer.cornerRadius = 12
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    return view
  }()

  private(set) public var checkoutButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Checkout", for: .normal)
    button.backgroundColor = #colorLiteral(red: 1, green: 0.8392156863, blue: 0.007843137255, alpha: 1)
    button.titleLabel?.font = .custom(.medium, size: 19)
    button.setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.0862745098, blue: 0.1019607843, alpha: 1), for: .normal)
    button.layer.cornerRadius = 12
    button.clipsToBounds = true
    return button
  }()

  private(set) public var dismissButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .darkGray
    return button
  }()

  private(set) public var headerLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.font = .custom(.medium, size: 26)
    view.textColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1)
    view.text = "Screen"
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  required init?(coder: NSCoder) {
    return nil
  }
}

private extension BoxOfficeBookingCustomView {
  func configureUI() {

    [headerLabel, dismissButton, collectionView, checkoutButton].forEach(containerView.addSubview)

    collectionView.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1490196078, alpha: 1)
    collectionView.contentInset = .init(top: 24, left: 24, bottom: 24, right: 24)

    addSubview(containerView)
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

      checkoutButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -64),
      checkoutButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      checkoutButton.heightAnchor.constraint(equalToConstant: 44),
      checkoutButton.widthAnchor.constraint(equalToConstant: 148),

      headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
      headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

      dismissButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
      dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

      collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
      collectionView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      collectionView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor, constant: -32)
    ])
  }
}

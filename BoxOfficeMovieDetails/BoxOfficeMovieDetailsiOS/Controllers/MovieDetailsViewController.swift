//
//  MovieDetailsViewController.swift
//  BoxOfficeMovieDetailsiOS
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import UIKit
import BoxOfficeMovieDetails

public final class MovieDetailsViewController: UIViewController {

  public var onBuyTicket: (() -> Void)?

  private var id: Int?
  private var loader: MovieLoader?

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private(set) public var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var metaLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var overviewLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var buyTicketButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Buy ticket", for: .normal)
    return button
  }()

  public  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)

    buyTicketButton.addTarget(self, action: #selector(didTapBuyTicket), for: .touchUpInside)

    loadingIndicator.startAnimating()
    loader?.load(id: id!, completion: { [weak self] result in

      if let movie = try? result.get() {
        self?.titleLabel.text = movie.title

        let runTime = Double(movie.length * 60).asString(style: .short)
        let genres = movie.genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        self?.metaLabel.text = "\(runTime) | \(genres)"
        self?.overviewLabel.text = movie.overview
      }

      self?.loadingIndicator.stopAnimating()
    })
  }
}

private extension MovieDetailsViewController {
  @objc func didTapBuyTicket() {
    onBuyTicket?()
  }
}

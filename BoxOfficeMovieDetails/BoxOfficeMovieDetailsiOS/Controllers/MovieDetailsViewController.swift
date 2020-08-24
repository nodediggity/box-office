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

public  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

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

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}


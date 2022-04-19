//
//  AboutViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 19.04.22.
//

import UIKit


protocol AboutViewControllerDelegate {

  func exitPressed()
  func dataProviderPressed()
}


class AboutViewController: UIViewController {

  private let model: AboutViewControllerDelegate

  init(model: AboutViewControllerDelegate) {
    self.model = model

    super.init(nibName: nil, bundle: nil)

    navigationItem.title = "About"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(exitPressed)
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.backgroundColor = .systemBackground

    let scrollView = createScrollView()
    scrollView.preservesSuperviewLayoutMargins = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}


// MARK: - Private
private extension AboutViewController {

  func createScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.contentInsetAdjustmentBehavior = .never

    let contentView = createContentView()
    contentView.preservesSuperviewLayoutMargins = true
    contentView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(contentView)

    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])

    return scrollView
  }

  func createContentView() -> UIView {
    let contentView = UIView()

    let providerLabel = UILabel()
    providerLabel.numberOfLines = 0
    providerLabel.font = UIFontConstants.main
    providerLabel.text = "The weather data is provided by Open-Meteo.com"
    providerLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(providerLabel)

    let providerButton = UIButton(type: .system)
    providerButton.contentHorizontalAlignment = .trailing
    providerButton.setImage(UIImage(systemName: "questionmark.circle")!, for: .normal)
    providerButton.addTarget(self, action: #selector(dataProviderPressed), for: .touchUpInside)
    providerButton.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(providerButton)

    let topConstraint = providerLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
    topConstraint.priority = .fittingSizeLevel
    let bottomConstraint = providerLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
    bottomConstraint.priority = .fittingSizeLevel
    NSLayoutConstraint.activate([
      providerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      providerLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
      providerLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
      topConstraint,
      bottomConstraint,

      providerButton.leadingAnchor.constraint(equalTo: providerLabel.trailingAnchor),
      providerButton.widthAnchor.constraint(equalToConstant: LayoutConstants.tapSize),
      providerButton.heightAnchor.constraint(equalToConstant: LayoutConstants.tapSize),
      providerButton.firstBaselineAnchor.constraint(equalTo: providerLabel.firstBaselineAnchor),
      providerButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      providerButton.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
      providerButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
    ])

    return contentView
  }

  @objc
  func exitPressed() {
    model.exitPressed()
  }

  @objc
  func dataProviderPressed() {
    model.dataProviderPressed()
  }
}

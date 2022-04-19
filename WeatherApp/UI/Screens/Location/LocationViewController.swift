//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import UIKit
import MapKit


protocol LocationViewControllerDelegate {

  var location: WeatherLocation { get }

  func setLocation(_ location: WeatherLocation)
  func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
  func cancelPressed()
  func donePressed()
  func saveLocation()
}


class LocationViewController: UIViewController, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

  private let model: LocationViewControllerDelegate
  private lazy var mapView = createMapView()
  private lazy var centerIconView = createCenterIconView()
  private lazy var searchBar = createSearchBar()
  private var initialLocationSet = false

  init(model: LocationViewControllerDelegate) {
    self.model = model

    super.init(nibName: nil, bundle: nil)

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelPressed)
    )
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(donePressed)
    )
    navigationItem.titleView = searchBar
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.backgroundColor = .systemBackground

    mapView.preservesSuperviewLayoutMargins = true
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)

    centerIconView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(centerIconView)

    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      centerIconView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
      centerIconView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
    ])

    let locationButton = createLocationButton()
    locationButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(locationButton)
    NSLayoutConstraint.activate([
      locationButton.widthAnchor.constraint(equalToConstant: LayoutConstants.tapSize),
      locationButton.heightAnchor.constraint(equalToConstant: LayoutConstants.tapSize),
      locationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      locationButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -LayoutConstants.spacing)
    ])

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognized))
    tapRecognizer.delegate = self
    view.addGestureRecognizer(tapRecognizer)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if !initialLocationSet {
      mapView.centerCoordinate = CLLocationCoordinate2D(
        latitude: model.location.latitude,
        longitude: model.location.longitude
      )
      initialLocationSet = true
    }
  }

  // MARK: - UIAdaptivePresentationControllerDelegate

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    model.saveLocation()
  }

  // MARK: - MKMapViewDelegate

  func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    guard initialLocationSet else { return }
    
    model.setLocation(WeatherLocation(
      latitude: mapView.centerCoordinate.latitude,
      longitude: mapView.centerCoordinate.longitude
    ))
  }

  // MARK: - UISearchBarDelegate

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    CLGeocoder().geocodeAddressString(searchBar.text ?? "") { [weak self] result, error in
      guard let self = self else { return }

      if let coordinate = result?.first?.location?.coordinate {
        self.mapView.centerCoordinate = coordinate
        self.searchBar.resignFirstResponder()
      } else {
        let alertController = UIAlertController(
          title: "Location Not Found",
          message: nil,
          preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alertController, animated: true)
      }
    }
  }

  // MARK: - UIGestureRecognizerDelegate

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return !(view.hitTest(touch.location(in: view), with: nil) is UIControl)
  }
}


// MARK: - Private
private extension LocationViewController {

  func createMapView() -> MKMapView {
    let mapView = MKMapView()
    mapView.isRotateEnabled = false
    mapView.delegate = self
    return mapView
  }

  func createCenterIconView() -> UIImageView {
    let iconView = UIImageView(image: UIImage(systemName: "circle.fill")!)
    return iconView
  }

  func createSearchBar() -> UISearchBar {
    let searchBar = UISearchBar()
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = "Search"
    searchBar.delegate = self
    return searchBar
  }

  func createLocationButton() -> UIButton {
    let locationButton = UIButton(type: .system)
    locationButton.backgroundColor = .systemBackground
    locationButton.setImage(UIImage(systemName: "location")!, for: .normal)
    locationButton.layer.cornerRadius = LayoutConstants.tapSize / 2
    locationButton.addTarget(self, action: #selector(currentLocationPressed), for: .touchUpInside)
    return locationButton
  }

  @objc
  func cancelPressed() {
    model.cancelPressed()
  }

  @objc
  func donePressed() {
    model.donePressed()
  }

  @objc
  func tapRecognized() {
    searchBar.resignFirstResponder()
  }

  @objc
  func currentLocationPressed() {
    model.getCurrentLocation { [weak self] result in
      guard let self = self else { return }

      switch result {
      case let .success(coordinate):
        self.mapView.centerCoordinate = coordinate
      case let .failure(error):
        let alertController = UIAlertController(
          title: "Error",
          message: error.localizedDescription,
          preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alertController, animated: true)
      }
    }
  }
}

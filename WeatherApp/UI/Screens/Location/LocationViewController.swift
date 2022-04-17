//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 17.04.22.
//

import UIKit
import MapKit
import CoreLocationUI


protocol LocationViewControllerDelegate {

  var location: WeatherLocation { get }

  func setLocation(_ location: WeatherLocation)
  func cancelPressed()
  func donePressed()
  func saveLocation()
}


class LocationViewController: UIViewController, UIAdaptivePresentationControllerDelegate, MKMapViewDelegate {

  private let model: LocationViewControllerDelegate
  private lazy var mapView = createMapView()
  private lazy var centerIconView = createCenterIconView()
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

  @objc
  func cancelPressed() {
    model.cancelPressed()
  }

  @objc
  func donePressed() {
    model.donePressed()
  }
}

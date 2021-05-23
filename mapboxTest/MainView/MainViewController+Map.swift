//
//  MainViewController+Map.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 23.05.2021.
//

import UIKit
import Mapbox
import MapboxSearch

extension MainViewController {
   func centerByUser() {
      guard let user = mapView.userLocation?.coordinate else { return }
      flyToCoordinate(user)
   }

   func flyToCoordinate(_ coordinate: CLLocationCoordinate2D, altitude: Double = 3000) {
      let camera = MGLMapCamera(lookingAtCenter: coordinate, altitude: altitude, pitch: 0, heading: 0)
      mapView.fly(to: camera, completionHandler: nil)
   }

   @objc func handleMapTap(sender: UITapGestureRecognizer) {
      // Convert tap location (CGPoint) to geographic coordinate (CLLocationCoordinate2D).
      let tapPoint: CGPoint = sender.location(in: mapView)
      let tapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: nil)
      viewModel.selectedCoordinate = tapCoordinate
      updateUserPin(to: tapCoordinate)

   }

   func updateUserPin(to coordinate: CLLocationCoordinate2D) {
      removeUserPin()
      createUserPin(at: coordinate)

      flyToCoordinate(coordinate)
      searchEngine.reverseGeocoding(options: SearchEngine.ReverseGeocodingOptions(point: coordinate, mode: .distance, types: [.address])) { [weak self] (result) in
         switch result {
         case .failure(let error):
            print(error.localizedDescription)
         case .success(let items):
            guard let self = self,
                  let address = items.first?.address,
                  let street = address.street else { return }
            var name = "\(street)"
            if let house = address.houseNumber {
               name += ", \(house)"
            }
            self.detailsVC.set(title: name)
            if !self.detailsFpc.isBeingPresented {
               self.detailsFpc.addPanel(toParent: self, animated: true)
            }
         }
      }
   }

   @objc func reloadResultInMapBounds() {
      // Load parking markers in visible bounds
      let boundingBox = MapboxSearch.BoundingBox(mapView.visibleCoordinateBounds.sw,
                                                 mapView.visibleCoordinateBounds.ne)
      let requestOptions = CategorySearchEngine.RequestOptions(proximity: mapView.centerCoordinate,
                                                               boundingBox: boundingBox,
                                                               navigationProfile: .cycling,
                                                               unsafeParameters: ["limit":"10"])
      categorySearchEngine.search(categoryName: "parking", options: requestOptions) { [weak self] response in
         guard let results = try? response.get() else { return }
         let points = results.map { SPointAnnotation($0.coordinate) }
         self?.viewModel.parkingAnnotations.send(points)
      }
   }
}


extension MainViewController: MGLMapViewDelegate {
   public func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
      // From the new camera obtain the center to test if it’s inside the boundaries.
      let newCameraCenter = newCamera.centerCoordinate

      // Test if the newCameraCenter are inside bounds
      return MGLCoordinateInCoordinateBounds(newCameraCenter, saintPetersburgBounds)
   }

   public func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
      guard reason != .programmatic else { return }
      // Load parking markers in visible bounds
      draggingRefreshTimer?.invalidate()
      draggingRefreshTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(reloadResultInMapBounds), userInfo: nil, repeats: false)
   }

   public func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
      style.localizeLabels(into: nil)
      setUpImages(for: style)
      if let user = mapView.userLocation?.coordinate, mapView.isUserLocationVisible {
         mapView.setCenter(user, zoomLevel: 12, animated: false)
      }
      viewModel.loadData()
   }
}

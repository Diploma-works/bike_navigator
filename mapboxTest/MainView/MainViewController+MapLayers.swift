//
//  MainViewController+MapLayers.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 23.05.2021.
//

import UIKit
import Mapbox

extension MainViewController {

   struct LayerIdentifiers {
      static let user = "user"
      static let userPin = "userPin"
      static let originRoute = "originRoute"
      static let bikeRoute = "bikeRoute"
      static let lane = "lane"
      static let laneInking = "laneInking"
      static let parking = "parking"
      static let parkingPin = "parkingPin"
   }

   func setUpImages(for style: MGLStyle) {
      if let image = UIImage(named: "user") {
         style.setImage(image, forName: LayerIdentifiers.userPin)
      }
      if let image = UIImage(named: "parking") {
         mapView.style?.setImage(image, forName: LayerIdentifiers.parkingPin)
      }
   }

   func createUserPin(at coordinate: CLLocationCoordinate2D) {
      let parkingSource = MGLShapeSource(identifier: LayerIdentifiers.user, shape: SPointAnnotation(coordinate), options: nil)
      let shapeLayer = MGLSymbolStyleLayer(identifier: LayerIdentifiers.user, source: parkingSource)

      shapeLayer.iconImageName = NSExpression(forConstantValue: LayerIdentifiers.userPin)
      mapView.style?.addSource(parkingSource)
      mapView.style?.addLayer(shapeLayer)
   }

   func removeUserPin() {
      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.user) {
         mapView.style?.removeLayer(layer)
      }
      if let source = mapView.style?.source(withIdentifier: LayerIdentifiers.user) {
         mapView.style?.removeSource(source)
      }
   }

   func createRouteLayer(newRoute: MGLShape, oldRoute: MGLShape, active: RouteType = .safe) {
      let source = MGLShapeSource(identifier: LayerIdentifiers.originRoute, shape: oldRoute, options: nil)
      mapView.style?.addSource(source)

      let layer = MGLLineStyleLayer(identifier: LayerIdentifiers.originRoute, source: source)
      let route1Color = active == .short ? ApplicationColors.mainOrange : ApplicationColors.darkOrange
      layer.lineColor = NSExpression(forConstantValue: route1Color)

      // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 9 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
      layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                     [9: 2, 12: 4, 18: 20])

      let source2 = MGLShapeSource(identifier: LayerIdentifiers.bikeRoute, shape: newRoute, options: nil)
      mapView.style?.addSource(source2)

      let layer2 = MGLLineStyleLayer(identifier: LayerIdentifiers.bikeRoute, source: source2)
      let route2Color = active == .safe ? ApplicationColors.mainCyan : ApplicationColors.darkCyan
      layer2.lineColor = NSExpression(forConstantValue: route2Color)
      layer2.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                      [9: 2, 12: 4, 18: 20])

      if active == .safe {
         mapView.style?.addLayer(layer)
         mapView.style?.addLayer(layer2)
      } else {
         mapView.style?.addLayer(layer2)
         mapView.style?.addLayer(layer)
      }

   }

   func removeRouteLayer() {
      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.originRoute) {
         mapView.style?.removeLayer(layer)
      }
      if let source = mapView.style?.source(withIdentifier: LayerIdentifiers.originRoute) {
         mapView.style?.removeSource(source)
      }
      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.bikeRoute) {
         mapView.style?.removeLayer(layer)
      }
      if let source = mapView.style?.source(withIdentifier: LayerIdentifiers.bikeRoute) {
         mapView.style?.removeSource(source)
      }
   }

   func updateParking(with annotations: [MGLPointAnnotation]) {
      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.parking) {
         mapView.style?.removeLayer(layer)
      }
      if let source = mapView.style?.source(withIdentifier: LayerIdentifiers.parking) {
         mapView.style?.removeSource(source)
      }

      let parkingSource = MGLShapeSource(identifier: LayerIdentifiers.parking, shapes: annotations, options: nil)
      let shapeLayer = MGLSymbolStyleLayer(identifier: LayerIdentifiers.parking, source: parkingSource)
      shapeLayer.iconImageName = NSExpression(forConstantValue: LayerIdentifiers.parkingPin)
      mapView.style?.addSource(parkingSource)
      mapView.style?.addLayer(shapeLayer)
   }

   func updateLanes(with lanes: MGLShape) {
      guard let style = mapView.style else { return }

      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.lane) {
         mapView.style?.removeLayer(layer)
      }
      if let layer = mapView.style?.layer(withIdentifier: LayerIdentifiers.laneInking) {
         mapView.style?.removeLayer(layer)
      }
      if let source = mapView.style?.source(withIdentifier: LayerIdentifiers.lane) {
         mapView.style?.removeSource(source)
      }

      let source = MGLShapeSource(identifier: LayerIdentifiers.lane, shape: lanes, options: nil)
      style.addSource(source)
      let layer = MGLLineStyleLayer(identifier: LayerIdentifiers.lane, source: source)

      // Set the line join and cap to a rounded end.
      layer.lineJoin = NSExpression(forConstantValue: "round")
      layer.lineCap = NSExpression(forConstantValue: "round")
      layer.lineColor = NSExpression(forConstantValue: UIColor(red: 255/255, green: 230/255, blue: 0/255, alpha: 1))
      layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                     [9: 2, 12: 4, 18: 20])
      let casingLayer = MGLLineStyleLayer(identifier: LayerIdentifiers.laneInking, source: source)
      casingLayer.lineJoin = layer.lineJoin
      casingLayer.lineCap = layer.lineCap
      casingLayer.lineGapWidth = layer.lineWidth
      casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
      casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])

      style.addLayer(layer)
      style.insertLayer(casingLayer, below: layer)
   }
}

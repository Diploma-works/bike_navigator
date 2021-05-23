//
//  MainViewController+Routing.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 23.05.2021.
//

import Turf
import Mapbox
import MapboxDirections

extension MainViewController {
   func buildRoute() {
      guard let origin = mapView.userLocation?.coordinate,
            let destination = viewModel.selectedCoordinate else { return }
      if !self.routesFpc.isBeingPresented {
         self.routesFpc.addPanel(toParent: self, animated: true)
      }

      let originWaypoint = Waypoint(coordinate: origin)
      let destinationWaypoint = Waypoint(coordinate: destination)

      let options = RouteOptions(waypoints: [originWaypoint, destinationWaypoint],
                                                  profileIdentifier: .cycling)

      // Building original route
      Directions.shared.calculate(options) { [weak self] (session, result) in
         switch result {
         case .failure(let error):
            print(error.localizedDescription)
         case .success(let response):
            guard let route = response.routes?.first?.shape else {
               return
            }
            self?.calculateNewRoute(oldRoute: route)
         }
      }
   }

   func calculateNewRoute(oldRoute: LineString) {
      guard let shapes = (viewModel.lanes.value as? MGLShapeCollectionFeature)?.shapes,
            let source = oldRoute.coordinates.first,
            let destination = oldRoute.coordinates.last else { return }

      // Prepare a list of bike lanes
      let lanes: [LineString] = shapes.compactMap { shape in
         if let polyline = shape as? MGLPolylineFeature {
            var coords: [CLLocationCoordinate2D] = []
            for i in 0..<polyline.pointCount {
               coords.append(polyline.coordinates[Int(i)])
            }
            return LineString(coords)
         }
         return nil
      }

      // Splitting original route to separate coordinates
      var splittedCoordinates: [CLLocationCoordinate2D] = []
      var coordinates: [[CLLocationCoordinate2D]] = []
      for i in 0..<oldRoute.coordinates.count - 1 {
         coordinates.append([oldRoute.coordinates[i], oldRoute.coordinates[i+1]])
      }
      for coord in coordinates {
         let distance = coord[0].distance(to: coord[1])
         for dist in stride(from: 0, to: distance, by: 10) {
            splittedCoordinates.append(LineString([coord[0], coord[1]]).coordinateFromStart(distance: dist)!)
         }
      }

      var fixedCoordinates: [CLLocationCoordinate2D] = []
      fixedCoordinates.append(source)
      var lanesDict: [Int: [CLLocationCoordinate2D]] = [:]

      // Finding the closest coordinate to original on bike lane
      for c in splittedCoordinates {
         var closest: CLLocationCoordinate2D? = nil
         var laneNum: Int? = nil
         for (laneIndex, l) in lanes.enumerated() {
            let fixed = l.closestCoordinate(to: c)!
            if closest == nil {
               closest = fixed.coordinate
               laneNum = laneIndex
            } else if closest!.distance(to: c) > fixed.coordinate.distance(to: c) {
               closest = fixed.coordinate
               laneNum = laneIndex
            }
         }
         if fixedCoordinates.last != closest {
            if let num = laneNum {
               if lanesDict[num] != nil {
                  lanesDict[num]?.append(closest!)
               } else {
                  lanesDict[num] = [closest!]
               }
            }

            // Removing coordinates that are opposite to the movement direction
            if abs(destination.latitude - source.latitude) * 10 > abs(destination.longitude - source.longitude) {
               if closest?.latitude.isBetween(source.latitude, destination.latitude) == true {
                  fixedCoordinates.append(closest!)
               }
            } else {
               if closest?.longitude.isBetween(source.longitude, destination.longitude) == true {
                  fixedCoordinates.append(closest!)
               }
            }
         }
      }
      fixedCoordinates.append(destination)

      // Removing useless lanes intersection
      for (_, points) in lanesDict {
         if points.count == 1 {
            fixedCoordinates.removeAll(where: { $0 == points[0] })
         }
      }

      // Removing coordinates that are laying on the one line
      var i = 0
      while i < fixedCoordinates.count - 3 {
         let p1 = fixedCoordinates[i]
         let p2 = fixedCoordinates[i+1]
         let p3 = fixedCoordinates[i+2]
         if p1.distance(to: p2) + p2.distance(to: p3) - p1.distance(to: p3) < 0.000001 {
            fixedCoordinates.remove(at: i+1)
         } else {
            i += 1
         }
      }

      // MARK: Test Zone
      //      i = 0
      //      while i < fixedCoordinates.count - 2 {
      //         let p1 = fixedCoordinates[i]
      //         let p2 = fixedCoordinates[i+1]
      //         if p1.distance(to: p2) < 200 {
      //            fixedCoordinates.remove(at: i+1)
      //         }
      //         i += 1
      //      }

      // MARK: End Test Zone

      let options = MapboxDirections.RouteOptions(waypoints: fixedCoordinates.map {Waypoint(coordinate: $0)}, profileIdentifier: .walking)

      // Building new route
      Directions.shared.calculate(options) { [weak self] (session, result) in
         switch result {
         case .failure(let error):
            print(error.localizedDescription)
         case .success(let response):
            guard let route = response.routes?.first?.shape else {
               return
            }
            let route1 = MGLPolylineFeature(coordinates: route.coordinates, count: UInt(route.coordinates.count))
            let route2 = MGLPolylineFeature(coordinates: oldRoute.coordinates, count: UInt(oldRoute.coordinates.count))
            self?.viewModel.routes = (route1, route2)
            self?.createRouteLayer(
               newRoute: route1,
               oldRoute: route2
            )
         }
      }
   }
}

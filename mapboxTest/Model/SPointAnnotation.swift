//
//  SPointAnnotation.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 04.05.2021.
//

import Mapbox

class SPointAnnotation: MGLPointAnnotation {
   
   init(_ coordinate: CLLocationCoordinate2D, title: String? = nil) {
      super.init()
      self.title = title
      self.coordinate = coordinate
   }

   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
}

extension CLLocationCoordinate2D {
   var toQueryParam: String {
      return "\(longitude),\(latitude)"
   }
}

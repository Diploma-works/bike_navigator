//
//  CellIdentifiable.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 09.05.2021.
//

protocol CellIdentifiable {
   static var identifier: String { get }
}

extension CellIdentifiable {

   static var identifier: String {
      String(describing: Self.self)
   }

}
